//
//  IconQuestsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IconQuestsViewController.h"
#import "Quest.h"
#import "QuestDetailsViewController.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "MediaModel.h"

@interface IconQuestsViewController() <ARISMediaViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,QuestDetailsViewControllerDelegate,StateControllerProtocol>
{
    UICollectionView *questIconCollectionView;
    
    int newItemsSinceLastView;
    
    NSArray *activeQuests;
    NSArray *completedQuests;
    
    id<QuestsViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UICollectionView *questIconCollectionView;

@end

@implementation IconQuestsViewController

@synthesize questIconCollectionView;

- (id) initWithDelegate:(id<QuestsViewControllerDelegate,StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        delegate = d;
        
        self.tabID = @"QUESTS";
        self.tabIconName = @"todo";
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        
  _ARIS_NOTIF_LISTEN_(@"ConnectionLost",self,@selector(removeLoadingIndicator),nil);
  _ARIS_NOTIF_LISTEN_(@"LatestPlayerQuestListsReceived",self,@selector(removeLoadingIndicator),nil); 
  _ARIS_NOTIF_LISTEN_(@"NewlyActiveQuestsAvailable",self,@selector(refreshViewFromModel),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyCompletedQuestsAvailable",self,@selector(refreshViewFromModel),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyChangedQuestsGameNotificationSent",self,@selector(incrementBadge),nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorViewBackdrop];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    UICollectionViewFlowLayout *questIconCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    questIconCollectionViewLayout.itemSize = CGSizeMake(100, 120);
    questIconCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    questIconCollectionViewLayout.minimumLineSpacing = 5.0;
    questIconCollectionViewLayout.minimumInteritemSpacing = 5.0;
    
    questIconCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:questIconCollectionViewLayout];
    questIconCollectionView.backgroundColor = [UIColor clearColor];
    questIconCollectionView.dataSource = self;
    questIconCollectionView.delegate = self;
    [questIconCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:questIconCollectionView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
	newItemsSinceLastView = 0;
    [self refreshViewFromModel];
	[self refresh];
}

- (void) refresh
{
	[self showLoadingIndicator];
}

- (void) showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:activityIndicator]];
	[activityIndicator startAnimating];
}

- (void) removeLoadingIndicator
{
	[[self navigationItem] setRightBarButtonItem:nil];
}

- (void) refreshViewFromModel
{
    /*
    NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"sortNum" ascending:YES]];
    activeQuests    = [_MODEL_GAME_.questsModel.currentActiveQuests    sortedArrayUsingDescriptors:sortDescriptors];
    //completedQuests = [_MODEL_GAME_.questsModel.currentCompletedQuests sortedArrayUsingDescriptors:sortDescriptors];
    completedQuests = [[NSArray alloc] init];
        
    [self.questIconCollectionView reloadData];
     */
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return activeQuests.count + completedQuests.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor]; 
    
    /*
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];
        
    Quest *q;
    if(indexPath.item < activeQuests.count) q = [activeQuests    objectAtIndex:indexPath.item];
    else                                      q = [completedQuests objectAtIndex:indexPath.item-activeQuests.count];
    
    CGRect textFrame = CGRectMake(0, (cell.contentView.frame.size.height-20), cell.contentView.frame.size.width, 20);
    UILabel *iconTitleLabel = [[UILabel alloc] initWithFrame:textFrame];
    iconTitleLabel.text = q.name;
    iconTitleLabel.textColor = [ARISTemplate ARISColorViewText];
    iconTitleLabel.backgroundColor = [UIColor clearColor];
    iconTitleLabel.textAlignment = NSTextAlignmentCenter;
    iconTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;// NSLineBreakByTruncatingTail;
    iconTitleLabel.font = [ARISTemplate ARISSubtextFont];
    [cell.contentView addSubview:iconTitleLabel];
    
    ARISMediaView *icon = [[ARISMediaView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.width) delegate:self];
    [icon setDisplayMode:ARISMediaDisplayModeAspectFit];
    if(q.icon_media_id != 0)
        [icon setMedia:[_MODEL_MEDIA_ mediaForId:q.icon_media_id]];
    else
        [icon setImage:[UIImage imageNamed:@"item.png"]];
    
    icon.layer.cornerRadius = 11.0f;
    [cell.contentView addSubview:icon];
     */
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{    
    Quest *q;
    if(indexPath.item < activeQuests.count) q = [activeQuests    objectAtIndex:indexPath.item];
    else                                      q = [completedQuests objectAtIndex:indexPath.item-activeQuests.count];

    [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q delegate:self] animated:YES];
}

- (void) questDetailsRequestsDismissal
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);             
}

//implement statecontrol stuff for webpage, but just delegate any requests
- (BOOL) displayTrigger:(Trigger *)t { return [delegate displayTrigger:t]; }
- (BOOL) displayInstance:(Instance *)i { return [delegate displayInstance:i]; }
- (BOOL) displayObjectType:(NSString *)type id:(int)type_id { return [delegate displayObjectType:type id:type_id]; }
- (void) displayTab:(NSString *)t { [delegate displayTab:t]; }
- (void) displayScannerWithPrompt:(NSString *)p { [delegate displayScannerWithPrompt:p]; }

@end
