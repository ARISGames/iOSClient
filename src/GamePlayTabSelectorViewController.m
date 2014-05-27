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

#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryViewController.h"
#import "MapViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"

#import "AppModel.h"
#import "ARISMediaView.h"

#import "GameObjectViewController.h"

@interface GamePlayTabSelectorViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIView *leaveGameButton;
    UILabel *leaveGameLabel;
    UIImageView *leaveGameArrow;
    UIView *leaveGameLine;

    NSMutableArray *viewControllers;
    NSMutableDictionary *viewControllersDict;

    id<GamePlayTabSelectorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation GamePlayTabSelectorViewController

- (id) initWithDelegate:(id<GamePlayTabSelectorViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
        viewControllers = [[NSMutableArray alloc] init];
        viewControllersDict = [[NSMutableDictionary alloc] init];
        [self refreshFromModel];
        _ARIS_NOTIF_LISTEN_(@"MODEL_TABS_NEW_AVAILABLE", self, @selector(refreshFromModel), nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_TABS_LESS_AVAILABLE", self, @selector(refreshFromModel), nil);
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
    gameName.text = _MODEL_GAME_.name;
    [headerView addSubview:gameName];

    ARISMediaView *gameIcon = [[ARISMediaView alloc] init];
    [gameIcon setDisplayMode:ARISMediaDisplayModeAspectFit];
    [gameIcon setFrame:CGRectMake(15, (headerHeight/2) - (35/2), 30, 35)];
    [gameIcon setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_GAME_.icon_media_id]];
    [headerView addSubview:gameIcon];

    [tableView setTableHeaderView:headerView];

    [self.view addSubview:tableView];
    if(!_MODEL_.disableLeaveGame) [self.view addSubview:leaveGameButton];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    tableView.frame = self.view.bounds;
    if(_MODEL_.disableLeaveGame) tableView.contentInset = UIEdgeInsetsMake(20,0,0,0);
    else                         tableView.contentInset = UIEdgeInsetsMake(20,0,44,0);

    leaveGameButton.frame = CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44);
    leaveGameLabel.frame = CGRectMake(30,0,self.view.bounds.size.width-30,44);
    leaveGameArrow.frame = CGRectMake(6,13,19,19);
    leaveGameLine.frame = CGRectMake(0,0,self.view.bounds.size.width,1);
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [tableView reloadData];
}

- (void) refreshFromModel
{
    NSArray *playerTabs = _ARIS_ARRAY_SORTED_ON_(_MODEL_TABS_.playerTabs,@"sort_index");
    viewControllers = [[NSMutableArray alloc] initWithCapacity:10];

    Tab *tab;
    for(int i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if(!viewControllersDict[tab.keyString])
        {
            ARISNavigationController *vc;
            if([tab.type isEqualToString:@"QUESTS"])
            {
                //if uses icon quest view
                if((BOOL)tab.content_id)
                {
                    IconQuestsViewController *iconQuestsViewController = [[IconQuestsViewController alloc] initWithDelegate:
                    (id<QuestsViewControllerDelegate,StateControllerProtocol>)delegate];
                    vc = [[ARISNavigationController alloc] initWithRootViewController:iconQuestsViewController];
                }
                else
                {
                    QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithDelegate:
                    (id<QuestsViewControllerDelegate,StateControllerProtocol>)delegate];
                    vc = [[ARISNavigationController alloc] initWithRootViewController:questsViewController];
                }
            }
            else if([tab.type isEqualToString:@"MAP"])
            {
                MapViewController *mapViewController = [[MapViewController alloc] initWithDelegate:
                    (id<MapViewControllerDelegate,StateControllerProtocol>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:mapViewController];
            }
            else if([tab.type isEqualToString:@"INVENTORY"])
            {
                InventoryViewController *inventoryViewController = [[InventoryViewController alloc] initWithDelegate:
                    (id<InventoryViewControllerDelegate,StateControllerProtocol>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:inventoryViewController];
            }
            else if([tab.type isEqualToString:@"DECODER"]) //text only
            {
                DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:
                    (id<DecoderViewControllerDelegate,StateControllerProtocol>)delegate inMode:1];
                vc = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            }
            else if([tab.type isEqualToString:@"SCANNER"]) //will be scanner only- supports both for legacy
            {
                DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithDelegate:
                    (id<DecoderViewControllerDelegate,StateControllerProtocol>)delegate inMode:tab.content_id];
                vc = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            }
            else if([tab.type isEqualToString:@"PLAYER"])
            {
                AttributesViewController *attributesViewController = [[AttributesViewController alloc] initWithDelegate:
                    (id<AttributesViewControllerDelegate,StateControllerProtocol>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:attributesViewController];
            }
            else if([tab.type isEqualToString:@"NOTEBOOK"])
            {
                NotebookViewController *notesViewController = [[NotebookViewController alloc] initWithDelegate:
                    (id<NotebookViewControllerDelegate,StateControllerProtocol>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:notesViewController];
            }
            if(vc) [viewControllersDict setObject:vc forKey:tab.keyString];
        }

        [viewControllers addObject:viewControllersDict[tab.keyString]];
    }

    if(self.view) [tableView reloadData];
}

- (ARISNavigationController *) firstViewController
{
    return viewControllers[0];
}

- (void) leaveGameButtonTouched
{
    [_MODEL_ leaveGame];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return viewControllers.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    c.opaque = NO;
    c.backgroundColor = [UIColor clearColor];
    c.textLabel.textColor = [ARISTemplate ARISColorSideNavigationText];
    c.textLabel.font = [ARISTemplate ARISButtonFont];

    ARISNavigationController *anc = viewControllers[indexPath.row];
    ARISGamePlayTabBarViewController *agptbvc = anc.viewControllers[0];

    if([agptbvc isKindOfClass:[MapViewController class]])
        c.textLabel.text = NSLocalizedString(@"MapViewTitleKey",@"");
    else c.textLabel.text = agptbvc.title;
    c.imageView.image = [UIImage imageNamed:agptbvc.tabIconName];

    return c;
}

- (void) requestDisplayTab:(NSString *)t
{
    NSArray *playerTabs = _MODEL_TABS_.playerTabs;
    Tab *tab;
    //Check by name
    for(int i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if([[tab.name lowercaseString] isEqualToString:[t lowercaseString]])
        {
            [delegate viewControllerRequestedDisplay:viewControllersDict[tab.keyString]];
            return;
        }
    }
    //Check by type
    for(int i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if([[tab.type lowercaseString] isEqualToString:[t lowercaseString]])
        {
            [delegate viewControllerRequestedDisplay:viewControllersDict[tab.keyString]];
            return;
        }
    }
}

- (void) requestDisplayScannerWithPrompt:(NSString *)p
{
    NSArray *playerTabs = _MODEL_TABS_.playerTabs;
    Tab *tab;
    for(int i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if([tab.type isEqualToString:@"SCANNER"])
        {
            [((DecoderViewController *)viewControllersDict[tab.keyString]) setPrompt:p];
            [delegate viewControllerRequestedDisplay:viewControllersDict[tab.keyString]];
            return;
        }
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate viewControllerRequestedDisplay:viewControllers[indexPath.row]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
