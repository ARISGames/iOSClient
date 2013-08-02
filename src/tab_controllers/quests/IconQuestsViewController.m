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
#import "AsyncMediaImageView.h"
#import "AppModel.h"
#import "AppServices.h"

#define ICONWIDTH 76
#define ICONHEIGHT 90
#define TEXTLABELHEIGHT 10
#define TEXTLABELPADDING 7

@interface IconQuestsViewController() <UICollectionViewDataSource,UICollectionViewDelegate,QuestDetailsViewControllerDelegate,StateControllerProtocol>
{
    UICollectionView *questIconCollectionView;
    UICollectionViewFlowLayout *questIconCollectionViewLayout;
    
    int newItemsSinceLastView;
    
    NSArray *activeQuests;
    NSArray *completedQuests;
    
    id<QuestsViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}

@end

@implementation IconQuestsViewController

- (id) initWithDelegate:(id<QuestsViewControllerDelegate,StateControllerProtocol>)d
{
    self = [super initWithNibName:@"IconQuestsViewController" bundle:nil];
    if(self)
    {
        delegate = d;
        
        self.tabID = @"QUESTS";
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"todoTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"todoTabBarUnselected"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList"                      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyActiveQuestsAvailable"             object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyCompletedQuestsAvailable"          object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedQuestsGameNotificationSent" object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    questIconCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    questIconCollectionViewLayout.itemSize = CGSizeMake(ICONWIDTH, ICONHEIGHT);
    questIconCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    questIconCollectionViewLayout.minimumLineSpacing = 30.0;
    questIconCollectionViewLayout.minimumInteritemSpacing = 10.0;
    
    questIconCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:questIconCollectionViewLayout];
    questIconCollectionView.dataSource = self;
    questIconCollectionView.delegate = self;
    [questIconCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:questIconCollectionView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
	newItemsSinceLastView = 0;
	[[AppServices sharedAppServices] updateServerQuestsViewed];
    [self refreshViewFromModel];
	[self refresh];
}

- (void) refresh
{
	[[AppServices sharedAppServices] fetchPlayerQuestList];
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
    NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"sortNum" ascending:YES]];
    activeQuests    = [[AppModel sharedAppModel].currentGame.questsModel.currentActiveQuests    sortedArrayUsingDescriptors:sortDescriptors];
    completedQuests = [[AppModel sharedAppModel].currentGame.questsModel.currentCompletedQuests sortedArrayUsingDescriptors:sortDescriptors];
        
    [questIconCollectionView reloadData];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [activeQuests count] + [completedQuests count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];
        
    Quest *q;
    if(indexPath.item < [activeQuests count]) q = [activeQuests    objectAtIndex:indexPath.item];
    else                                      q = [completedQuests objectAtIndex:indexPath.item-[activeQuests count]];
    
    AsyncMediaImageView *icon = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height - TEXTLABELHEIGHT - (2*TEXTLABELPADDING))];
    if(q.iconMediaId != 0) [icon loadMedia:[[AppModel sharedAppModel] mediaForMediaId:q.iconMediaId ofType:@"PHOTO"]];
    else                   [icon setImage:[UIImage imageNamed:@"item.png"]];
    icon.layer.cornerRadius = 11.0f;
    [cell.contentView addSubview:icon];
    
    CGRect textFrame = CGRectMake(0, (cell.contentView.frame.size.height-TEXTLABELHEIGHT - TEXTLABELPADDING), cell.contentView.frame.size.width, TEXTLABELHEIGHT);
    UILabel *iconTitleLabel = [[UILabel alloc] initWithFrame:textFrame];
    iconTitleLabel.text = q.name;
    iconTitleLabel.textColor = [UIColor whiteColor];
    iconTitleLabel.backgroundColor = [UIColor clearColor];
    iconTitleLabel.textAlignment = NSTextAlignmentCenter;
    iconTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    iconTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    [cell.contentView addSubview:iconTitleLabel];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{    
    Quest *q;
    if(indexPath.item < [activeQuests count]) q = [activeQuests    objectAtIndex:indexPath.item];
    else                                      q = [completedQuests objectAtIndex:indexPath.item-[activeQuests count]];

    [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q delegate:self] animated:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [self.navigationController popToViewController:self animated:YES];
    [delegate displayScannerWithPrompt:p];
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    [self.navigationController popToViewController:self animated:YES];
    return [delegate displayGameObject:g fromSource:s];
}

- (void) displayTab:(NSString *)t
{
    [self.navigationController popToViewController:self animated:YES];
    [delegate displayTab:t];
}

@end
