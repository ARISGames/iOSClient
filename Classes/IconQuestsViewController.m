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

@synthesize quests, isLink, activeSort;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"117-todo"];
        activeSort = 1;
		self.isLink = NO;
    }
	
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
	NSLog(@"IconQuestsViewController: silenceNextUpdate. Count is %d",silenceNextServerUpdateCount );
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    //register for notifications
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList" object:nil];
    [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewQuestListReady" object:nil];
    [dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
    
	NSLog(@"IconQuestsViewController: Quests View Loaded");
    
    [questIconCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	
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
	NSLog(@"IconQuestsViewController: Refreshing view from model");
	
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSLog(@"IconQuestsViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
	
    int newItems = 0;
    
	//Update the badge
	if (silenceNextServerUpdateCount < 1) {
		//Check if anything is new since last time
		NSArray *newActiveQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
		for (Quest *quest in newActiveQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:ACTIVE_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
				newItems++;
                quest.sortNum = activeSort;
                activeSort++;
			}
		}
        
        NSArray *newCompletedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
        
        for (Quest *quest in newCompletedQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:COMPLETED_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
                [appDelegate playAudioAlert:@"inventoryChange" shouldVibrate:YES];
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
    
    if(newItems >0) [questIconCollectionView reloadData];
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
    
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
    
    NSArray *activeQuests = [self.quests objectAtIndex:ACTIVE_SECTION];
    NSArray *completedQuests = [self.quests objectAtIndex:COMPLETED_SECTION];
    
    int questNumber = indexPath.item;
    
    Quest *currentQuest;
    if(questNumber >= [activeQuests count]){
        questNumber -= [activeQuests count];
        currentQuest = [completedQuests objectAtIndex:questNumber];
    }
    else currentQuest = [activeQuests objectAtIndex:questNumber];
    
    UIImage *iconImage;
    if(currentQuest.iconMediaId != 0){
        Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: currentQuest.iconMediaId];
        iconImage = [UIImage imageWithData:iconMedia.image];
    }
    else iconImage = [UIImage imageNamed:@"item.png"];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height - TEXTLABELHEIGHT - (2*TEXTLABELPADDING))];
    [iconImageView setImage:iconImage];
       // iconImageView.layer.cornerRadius = 9.0f;
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
