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
#import "AppServices.h"
#import "UIColor+ARISColors.h"

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
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"todoTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"todoTabBarSelected"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList"                      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyActiveQuestsAvailable"             object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyCompletedQuestsAvailable"          object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedQuestsGameNotificationSent" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorViewBackdrop];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    UICollectionViewFlowLayout *questIconCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    questIconCollectionViewLayout.itemSize = CGSizeMake(76, 90);
    questIconCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    questIconCollectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    questIconCollectionViewLayout.minimumLineSpacing = 30.0;
    questIconCollectionViewLayout.minimumInteritemSpacing = 10.0;
    
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
        
    [self.questIconCollectionView reloadData];
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
    
    CGRect textFrame = CGRectMake(0, (cell.contentView.frame.size.height-20), cell.contentView.frame.size.width, 20);
    UILabel *iconTitleLabel = [[UILabel alloc] initWithFrame:textFrame];
    iconTitleLabel.text = q.name;
    iconTitleLabel.textColor = [UIColor ARISColorViewText];
    iconTitleLabel.backgroundColor = [UIColor clearColor];
    iconTitleLabel.textAlignment = NSTextAlignmentCenter;
    iconTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;// NSLineBreakByTruncatingTail;
    iconTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    [cell.contentView addSubview:iconTitleLabel];
    
    CGRect iconFrame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height-(textFrame.size.height+7));
    ARISMediaView *icon;
    if(q.iconMediaId != 0)
        icon = [[ARISMediaView alloc] initWithFrame:iconFrame media:[[AppModel sharedAppModel] mediaForMediaId:q.iconMediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFit delegate:self];
    else
        icon = [[ARISMediaView alloc] initWithFrame:iconFrame image:[UIImage imageNamed:@"item.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
    
    icon.layer.cornerRadius = 11.0f;
    [cell.contentView addSubview:icon];
    
    return cell;
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{    
    Quest *q;
    if(indexPath.item < [activeQuests count]) q = [activeQuests    objectAtIndex:indexPath.item];
    else                                      q = [completedQuests objectAtIndex:indexPath.item-[activeQuests count]];

    [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q delegate:self] animated:YES];
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

- (void) questDetailsRequestsDismissal
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
