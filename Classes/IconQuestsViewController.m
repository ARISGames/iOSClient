//
//  IconQuestsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IconQuestsViewController.h"

static NSString * const OPTION_CELL = @"quest";
static int const ACTIVE_SECTION = 0;
static int const COMPLETED_SECTION = 1;
int itemsPerColumnWithoutScrolling;
int initialHeight;

BOOL supportsCollectionView = NO;

NSString *const kIconQuestsHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #E9E9E9;"
@"		color: #000000;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0;"
@"	}"
@"	h1 {"
@"		color: #000000;"
@"		font-size: 18px;"
@"		font-style: bold;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0 0 10 0;"
@"	}"
@"	--></style>"
@"</head>"
@"<body></div><div style=\"position:relative; top:0px; background-color:#DDDDDD; border-style:ridge; border-width:3px; border-radius:11px; border-color:#888888;padding:15px;\"><h1>%@</h1>%@</div></body>"
@"</html>";

@implementation IconQuestsViewController

@synthesize quests;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"117-todo"];
        sortedQuests = [[NSArray alloc] init];
       
        //register for notifications
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList" object:nil];
        [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewQuestListReady" object:nil];
        [dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
    }
	
    return self;
}

- (void)silenceNextUpdate{
	silenceNextServerUpdateCount++;
	NSLog(@"IconQuestsViewController: silenceNextUpdate. Count is %d",silenceNextServerUpdateCount);
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	NSLog(@"IconQuestsViewController: Quests View Loaded");
    
    float currentVersion = 6.0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion){
        
        supportsCollectionView = YES;
        
        questIconCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        questIconCollectionViewLayout.itemSize = CGSizeMake(ICONWIDTH, ICONHEIGHT);
        questIconCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        questIconCollectionViewLayout.minimumLineSpacing = 30.0;
        questIconCollectionViewLayout.minimumInteritemSpacing = 10.0;
        
        questIconCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:questIconCollectionViewLayout];
        questIconCollectionView.dataSource = self;
        questIconCollectionView.delegate = self;
        [questIconCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [self.view addSubview:questIconCollectionView];
    }
    else {
        supportsCollectionView = NO;
        
        CGRect fullScreenRect=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        questIconScrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
        questIconScrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        questIconScrollView.backgroundColor = [UIColor blackColor];

        initialHeight = self.view.frame.size.height;
        itemsPerColumnWithoutScrolling = self.view.frame.size.height/ICONHEIGHT + .5;
        itemsPerColumnWithoutScrolling--;
        
        [self.view addSubview:questIconScrollView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"IconQuestsViewController: viewDidAppear");
    
    if (![AppModel sharedAppModel].loggedIn || [AppModel sharedAppModel].currentGame.gameId==0) {
        NSLog(@"QuestsVC: Player is not logged in, don't refresh");
        return;
    }
    
	[[AppServices sharedAppServices] updateServerQuestsViewed];
	
	[self refresh];
	
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	silenceNextServerUpdateCount = 0;
    
    [self refreshViewFromModel];
    
}

-(void)dismissTutorial{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindQuestsTab];
}

- (void)refresh {
	NSLog(@"IconQuestsViewController: refresh requested");
	if ([AppModel sharedAppModel].loggedIn) [[AppServices sharedAppServices] fetchQuestList];
	[self showLoadingIndicator];
}


-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:nil];
	NSLog(@"IconQuestsViewController: removeLoadingIndicator");
}

-(void)refreshViewFromModel {
    if([RootViewController sharedRootViewController].usesIconQuestView){
	NSLog(@"IconQuestsViewController: Refreshing view from model");
	
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSLog(@"IconQuestsViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
	
    int newItems = 0;
    
	//Update the badge
	if (silenceNextServerUpdateCount < 1) {
		//Check if anything is new since last time
		NSArray *newActiveQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
        NSArray *newCompletedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
		
        for (Quest *quest in newCompletedQuestsArray) {
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:COMPLETED_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;
			}
			if (match == NO) {
                [appDelegate playAudioAlert:@"inventoryChange" shouldVibrate:YES];
                
                if(quest.fullScreenNotification)
                    [[RootViewController sharedRootViewController] enqueuePopOverWithTitle:NSLocalizedString(@"QuestsViewQuestCompletedKey", nil) description:quest.name webViewText:quest.description andMediaId:quest.mediaId];
                else
                {
                    NSString *notifString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestsViewQuestCompletedKey", nil), quest.name] ;
                    [[RootViewController sharedRootViewController] enqueueNotificationWithFullString: notifString andBoldedString:quest.name];
                }
			}
		}
        
        for (Quest *quest in newActiveQuestsArray) {
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:ACTIVE_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
                newItems++;
                
                if(quest.fullScreenNotification)
                    [[RootViewController sharedRootViewController] enqueuePopOverWithTitle:NSLocalizedString(@"QuestViewNewQuestKey", nil) description:quest.name webViewText:quest.description andMediaId:quest.mediaId];
                else
                {
                    NSString *notifString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"QuestViewNewQuestKey", nil), quest.name] ;
                    [[RootViewController sharedRootViewController] enqueueNotificationWithFullString: notifString andBoldedString:quest.name];
                }
            }
		}
        
		if (newItems > 0) {
			newItemsSinceLastView += newItems;
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
			
			if (![AppModel sharedAppModel].hasSeenQuestsTabTutorial){
                //Put up the tutorial tab
				[[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController 
                                                                                                                                 type:tutorialPopupKindQuestsTab 
                                                                                                                                title:NSLocalizedString(@"QuestViewNewQuestKey", @"")
                                                                                                                              message:NSLocalizedString(@"QuestViewNewQuestMessageKey", @"")];
				[AppModel sharedAppModel].hasSeenQuestsTabTutorial = YES;
                [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
			}
		}
		else if (newItemsSinceLastView < 1) self.tabBarItem.badgeValue = nil;
	}
	else {
		newItemsSinceLastView = 0;
		self.tabBarItem.badgeValue = nil;
	}
	
	//rebuild the list
	NSArray *activeQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
	NSArray *completedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
    
	self.quests = [NSArray arrayWithObjects:activeQuestsArray, completedQuestsArray, nil];
    
    NSMutableArray *combinedQuests = [[NSMutableArray alloc] initWithArray:[self.quests objectAtIndex:ACTIVE_SECTION]];
    [combinedQuests addObjectsFromArray:[self.quests objectAtIndex:COMPLETED_SECTION]];
	
	NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortNum"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    sortedQuests = [combinedQuests sortedArrayUsingDescriptors:sortDescriptors];
    
    if(supportsCollectionView) [questIconCollectionView reloadData];
    else [self createIcons];
    }
    
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
}

-(void)createIcons{
	NSLog(@"IconQuestsVC: Constructing Icons");
    
    for (UIView *view in [questIconScrollView subviews]) {
        [view removeFromSuperview];
    }
    
    for(int i = 0; i < [sortedQuests count]; i++){
        Quest *currentQuest = [sortedQuests objectAtIndex:i];
        int xMargin = truncf((questIconScrollView.frame.size.width - ICONSPERROW * ICONWIDTH)/(ICONSPERROW +1));
        int yMargin = truncf((initialHeight - itemsPerColumnWithoutScrolling * ICONHEIGHT)/(itemsPerColumnWithoutScrolling + 1));
        int row = (i/ICONSPERROW);
        int xOrigin = (i % ICONSPERROW) * (xMargin + ICONWIDTH) + xMargin;
        int yOrigin = row * (yMargin + ICONHEIGHT) + yMargin;
        
        UIImage *iconImage;
        if(currentQuest.iconMediaId != 0){
            Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: currentQuest.iconMediaId];
            iconImage = [UIImage imageWithData:iconMedia.image];
        }
        else iconImage = [UIImage imageNamed:@"item.png"];
        IconQuestsButton *iconButton = [[IconQuestsButton alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, ICONWIDTH, ICONHEIGHT) andImage:iconImage andTitle:currentQuest.name];
        iconButton.tag = i;
        [iconButton addTarget:self action:@selector(questSelected:) forControlEvents:UIControlEventTouchUpInside];
        iconButton.imageView.layer.cornerRadius = 9.0;
        [questIconScrollView addSubview:iconButton];
        [iconButton setNeedsDisplay];
    }
	
	NSLog(@"QuestsVC: Icons created");
}

- (void) questSelected: (id)sender {
    UIButton *button = (UIButton*)sender;
    
    Quest *questSelected = [sortedQuests objectAtIndex:button.tag];

    QuestDetailsViewController *questDetailsViewController =[[QuestDetailsViewController alloc] initWithQuest: questSelected];
    questDetailsViewController.navigationItem.title = questSelected.name;
    [[self navigationController] pushViewController:questDetailsViewController animated:YES];
}


#pragma mark CollectionView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.quests count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    int questNumber = indexPath.item;
    
    Quest *currentQuest = [sortedQuests objectAtIndex:questNumber];
    
    UIImage *iconImage;
    if(currentQuest.iconMediaId != 0){
        Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: currentQuest.iconMediaId];
        iconImage = [UIImage imageWithData:iconMedia.image];
    }
    else iconImage = [UIImage imageNamed:@"item.png"];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height - TEXTLABELHEIGHT - (2*TEXTLABELPADDING))];
    [iconImageView setImage:iconImage];
    iconImageView.layer.cornerRadius = 11.0f;
    [cell.contentView addSubview:iconImageView];
    
    CGRect textFrame = CGRectMake(0, (cell.contentView.frame.size.height-TEXTLABELHEIGHT - TEXTLABELPADDING), cell.contentView.frame.size.width, TEXTLABELHEIGHT);
    UILabel *iconTitleLabel = [[UILabel alloc] initWithFrame:textFrame];
    iconTitleLabel.text = currentQuest.name;
    iconTitleLabel.textColor = [UIColor whiteColor];
    iconTitleLabel.backgroundColor = [UIColor clearColor];
    iconTitleLabel.textAlignment = UITextAlignmentCenter;
    iconTitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    iconTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [cell.contentView addSubview:iconTitleLabel];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        NSArray *activeQuests = [self.quests objectAtIndex:ACTIVE_SECTION];
        NSArray *completedQuests = [self.quests objectAtIndex:COMPLETED_SECTION];
    
        int questNumber = indexPath.item;
    
        Quest *questSelected;
        if(questNumber >= [activeQuests count]){
            questNumber -= [activeQuests count];
            questSelected = [completedQuests objectAtIndex:questNumber];
        }
        else questSelected = [activeQuests objectAtIndex:questNumber];
        QuestDetailsViewController *questDetailsViewController =[[QuestDetailsViewController alloc] initWithQuest: questSelected];
        questDetailsViewController.navigationItem.title = questSelected.name;
        [[self navigationController] pushViewController:questDetailsViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidUnload {
    questIconCollectionView = nil;
    [super viewDidUnload];
}
@end
