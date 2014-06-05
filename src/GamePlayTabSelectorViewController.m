//
//  GamePlayTabSelectorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import "GamePlayTabSelectorViewController.h"
#import "ARISNavigationController.h"
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "ARISTemplate.h"

#import "MapViewController.h"
#import "NotebookViewController.h"
#import "Game.h"
#import "ARISMediaView.h"

#import "NpcViewController.h"
#import "ItemViewController.h"
#import "NodeViewController.h"
#import "WebPageViewController.h"

@interface GamePlayTabSelectorViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIView *leaveGameButton;
    UILabel *leaveGameLabel;
    UIImageView *leaveGameArrow;
    UIView *leaveGameLine;
    
    NSMutableArray *viewControllers; 
    id<GamePlayTabSelectorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation GamePlayTabSelectorViewController
@synthesize viewControllers;

- (id) initWithViewControllers:(NSMutableArray *)vcs delegate:(id<GamePlayTabSelectorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        viewControllers = vcs;
        delegate = d;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectTab:)
                                                 name:@"TabWasDisplayed"
                                                 object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTabTable) name:@"UpdateTabTable" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorSideNavigationBackdrop];
    
    tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.opaque = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.bounces = NO;
    
    leaveGameButton = [[UIView alloc] init];
    leaveGameButton.userInteractionEnabled = YES;
    leaveGameButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    leaveGameButton.opaque = NO;
    [leaveGameButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveGameButtonTouched)]];  
    
    leaveGameLabel = [[UILabel alloc] init];  
    leaveGameLabel.textAlignment = NSTextAlignmentLeft;
    leaveGameLabel.font = [ARISTemplate ARISButtonFont];
    leaveGameLabel.text = NSLocalizedString(@"BogusTitleKey", @""); //leave game text
    leaveGameLabel.textColor = [ARISTemplate ARISColorText]; 
    leaveGameLabel.accessibilityLabel = @"Leave Game";  
    
    leaveGameArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowBack"]];
    
    leaveGameLine = [[UIView alloc] init];
    leaveGameLine.backgroundColor = [UIColor ARISColorLightGray]; 
    
    [leaveGameButton addSubview:leaveGameLine];
    [leaveGameButton addSubview:leaveGameLabel];
    [leaveGameButton addSubview:leaveGameArrow];
    
    int headerHeight = 40;
    
    CGRect headerFrame = CGRectMake(0, 0, self.view.bounds.size.width, headerHeight);
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = headerFrame;
    
    UILabel *gameName = [[UILabel alloc] init];
    gameName.frame = CGRectMake(57, (headerHeight/2) - (35/2), 200, 35);
    gameName.text = [AppModel sharedAppModel].currentGame.name;
    [headerView addSubview:gameName];
    
    if ([AppModel sharedAppModel].currentGame.iconMedia) {
        ARISMediaView *gameIcon = [[ARISMediaView alloc] init];
        [gameIcon setFrame:CGRectMake(15, (headerHeight/2) - (35/2), 30, 35)];
        [gameIcon setMedia:[AppModel sharedAppModel].currentGame.iconMedia];
        [headerView addSubview:gameIcon];
    }

    
    [tableView setTableHeaderView:headerView];
    
    [self.view addSubview:tableView]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    tableView.frame = self.view.bounds;
    tableView.contentInset = UIEdgeInsetsMake(20,0,0,0);
    
    leaveGameButton.frame = CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44); 
    leaveGameLabel.frame = CGRectMake(30,0,self.view.bounds.size.width-30,44);
    leaveGameArrow.frame = CGRectMake(6,13,19,19); 
    leaveGameLine.frame = CGRectMake(0,0,self.view.bounds.size.width,1);
    
    if(![AppModel sharedAppModel].disableLeaveGame)
    {
        tableView.contentInset = UIEdgeInsetsMake(20,0,44,0);
        [self.view addSubview:leaveGameButton];
    } 
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [tableView reloadData];
}

- (void) leaveGameButtonTouched
{
    [delegate gameRequestsDismissal];
}

- (ARISGamePlayTabBarViewController *) tabBarVCFromNavC:(ARISNavigationController *)anc
{
    if(![anc isKindOfClass:[ARISNavigationController class]]) return nil;
    if([[anc.viewControllers objectAtIndex:0] isKindOfClass:[ARISGamePlayTabBarViewController class]])
        return (ARISGamePlayTabBarViewController *)[anc.viewControllers objectAtIndex:0];
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *space = [[UIView alloc] init];
    space.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 15.0f);
    space.backgroundColor = [UIColor clearColor];
    return space;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [viewControllers count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    c.opaque = NO;
    c.backgroundColor = [UIColor clearColor];
    c.textLabel.textColor = [ARISTemplate ARISColorSideNavigationText];
    c.textLabel.font = [ARISTemplate ARISButtonFont];
    
    ARISNavigationController *anc = (ARISNavigationController *)[viewControllers objectAtIndex:indexPath.row];
    ARISGamePlayTabBarViewController *agptbvc = [anc.viewControllers objectAtIndex:0];
    
    while([c.contentView.subviews count] > 0)
        [[c.contentView.subviews objectAtIndex:0] removeFromSuperview];
    
    if([agptbvc isKindOfClass:[MapViewController class]])
        c.textLabel.text = NSLocalizedString(@"MapViewTitleKey",@"");
    else if([agptbvc isKindOfClass:[NotebookViewController class]])
           c.textLabel.text = [NSString stringWithFormat:@" %@",agptbvc.title];
    else if([agptbvc isKindOfClass:[NpcViewController class]])
    {
        NpcViewController *npcViewController = (NpcViewController *)agptbvc;
        c.textLabel.text = [npcViewController getTabTitle];
        c.imageView.image = [UIImage imageNamed:@"star_gray.png"];
    }
    else if ([agptbvc isKindOfClass:[ItemViewController class]])
    {
        ItemViewController *itemViewController = (ItemViewController *)agptbvc;
        c.textLabel.text = [itemViewController getTabTitle];
        c.imageView.image = [UIImage imageNamed:@"star_gray.png"];
    }
    else if ([agptbvc isKindOfClass:[NodeViewController class]])
    {
        NodeViewController *nodeViewController = (NodeViewController *)agptbvc;
        c.textLabel.text = [nodeViewController getTabTitle];
        c.imageView.image = [UIImage imageNamed:@"star_gray.png"];
    }
    else if ([agptbvc isKindOfClass:[WebPageViewController class]])
    {
        WebPageViewController *webPageViewController = (WebPageViewController *)agptbvc;
        c.textLabel.text = [webPageViewController getTabTitle];
        c.imageView.image = [UIImage imageNamed:@"star_gray.png"];
    }
    else
        c.textLabel.text = agptbvc.title;
    if ([agptbvc respondsToSelector:@selector(tabIconName)])
        c.imageView.image = [UIImage imageNamed:agptbvc.tabIconName];
    
    //DOESNT WORK \/
    c.imageView.frame = CGRectMake(5,5,c.frame.size.height-10,c.frame.size.height-10); 
    c.textLabel.frame = CGRectMake(c.frame.size.height,5,c.frame.size.width-c.frame.size.height,c.frame.size.height-10);  
    
    return c;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate viewControllerRequestedDisplay:[viewControllers objectAtIndex:indexPath.row]];
}

- (void) selectTab:(NSNotification *) notification
{
    NSDictionary *arisNavTab = notification.userInfo;
    ARISNavigationController *tab = [arisNavTab objectForKey:@"tab"];
    for (int i = 0; i < viewControllers.count; i++) {
        if ([tab isEqual:[viewControllers objectAtIndex:i]]) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void) refreshTabTable
{
    [tableView reloadData];
}

- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
