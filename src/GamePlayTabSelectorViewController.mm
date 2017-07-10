//
//  GamePlayTabSelectorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import "GamePlayTabSelectorViewController.h"
#import "ARISNavigationController.h"
#import "GamePlayTabBarViewControllerProtocol.h"
#import "GamePlayTabSelectorCell.h"

#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "InventoryViewController.h"
#import "MapViewController.h"
#import "AttributesViewController.h"
#import "NotebookViewController.h"
#import "DecoderViewController.h"
#import "ScannerViewController.h"
#import "AugmentedViewController.h"

#import "DialogViewController.h"
#import "ItemViewController.h"
#import "PlaqueViewController.h"
#import "WebPageViewController.h"

#import "AppModel.h"
#import "ARISMediaView.h"

@interface GamePlayTabSelectorViewController () <UITableViewDelegate, UITableViewDataSource, GamePlayTabSelectorCellDelegate>
{
    UITableView *tableView;
    UIView *leaveGameButton;
    UILabel *leaveGameLabel;
    UIImageView *leaveGameArrow;
    UIView *leaveGameLine;

    NSArray *playerTabs;
    NSMutableDictionary *viewControllersDict;
    NSMutableArray *viewControllers;

    id<GamePlayTabSelectorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation GamePlayTabSelectorViewController

- (id) initWithDelegate:(id<GamePlayTabSelectorViewControllerDelegate>)d;
{
  if(self = [super init])
  {
    delegate = d;
    viewControllersDict = [[NSMutableDictionary alloc] init];
    viewControllers = [[NSMutableArray alloc] init];
    [self refreshFromModel];
    _ARIS_NOTIF_LISTEN_(@"MODEL_TABS_NEW_AVAILABLE",  self, @selector(refreshFromModel), nil);
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
  
  long headerHeight = 40;
  
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
  if(_MODEL_GAME_.icon_media_id == 0) [gameIcon setImage:[UIImage imageNamed:@"logo_icon"]];
  else [gameIcon setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_GAME_.icon_media_id]];
  [headerView addSubview:gameIcon];
  
  [tableView setTableHeaderView:headerView];
  
  [self.view addSubview:tableView];
  if(_MODEL_.leave_game_enabled) [self.view addSubview:leaveGameButton];
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  tableView.frame = self.view.bounds;
  if(_MODEL_.leave_game_enabled) tableView.contentInset = UIEdgeInsetsMake(20,0,44,0);
  else                           tableView.contentInset = UIEdgeInsetsMake(20,0,0,0);
  
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
    playerTabs = _ARIS_ARRAY_SORTED_ON_(_MODEL_TABS_.playerTabs,@"sort_index");
    viewControllers = [[NSMutableArray alloc] initWithCapacity:playerTabs.count];

    Tab *tab;
    for(long i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if(!viewControllersDict[[NSNumber numberWithLong:tab.tab_id]])
        {
            ARISNavigationController *vc;
            if([tab.type isEqualToString:@"QUESTS"])
            {
                //if uses icon quest view
                if(tab.info && ![tab.info isEqualToString:@""])
                {
                    IconQuestsViewController *iconQuestsViewController = [[IconQuestsViewController alloc] initWithTab:tab delegate:
                    (id<QuestsViewControllerDelegate>)delegate];
                    vc = [[ARISNavigationController alloc] initWithRootViewController:iconQuestsViewController];
                }
                else
                {
                    QuestsViewController *questsViewController = [[QuestsViewController alloc] initWithTab:tab delegate:
                    (id<QuestsViewControllerDelegate>)delegate];
                    vc = [[ARISNavigationController alloc] initWithRootViewController:questsViewController];
                }
            }
            else if([tab.type isEqualToString:@"MAP"])
            {
                MapViewController *mapViewController = [[MapViewController alloc] initWithTab:tab delegate:
                    (id<MapViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:mapViewController];
            }
            else if([tab.type isEqualToString:@"INVENTORY"])
            {
                InventoryViewController *inventoryViewController = [[InventoryViewController alloc] initWithTab:tab delegate:
                    (id<InventoryViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:inventoryViewController];
            }
            else if([tab.type isEqualToString:@"DECODER"]) //text only
            {
                DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithTab:tab delegate:
                                                                (id<DecoderViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
            }
            else if([tab.type isEqualToString:@"SCANNER"]) //will be scanner only- supports both for legacy
            {
                ScannerViewController *scannerViewController = [[ScannerViewController alloc] initWithTab:tab delegate:
                                                                (id<ScannerViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:scannerViewController];
            }
            else if([tab.type isEqualToString:@"AUGMENTED"])
            {
#if TARGET_OS_SIMULATOR
                DecoderViewController *decoderViewController = [[DecoderViewController alloc] initWithTab:tab delegate:
                                                                (id<DecoderViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:decoderViewController];
#else
                AugmentedViewController *augmentedViewController = [[AugmentedViewController alloc] initWithTab:tab delegate:
                                                                (id<AugmentedViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:augmentedViewController];
#endif
            }
            else if([tab.type isEqualToString:@"PLAYER"])
            {
                AttributesViewController *attributesViewController = [[AttributesViewController alloc] initWithTab:tab delegate:
                    (id<AttributesViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:attributesViewController];
            }
            else if([tab.type isEqualToString:@"NOTEBOOK"])
            {
                NotebookViewController *notesViewController = [[NotebookViewController alloc] initWithTab:tab delegate:
                    (id<NotebookViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:notesViewController];
            }
            //non-standard
            else if([tab.type isEqualToString:@"DIALOG"])
            {
                DialogViewController *dialogViewController = [[DialogViewController alloc] initWithTab:tab delegate:
                    (id<DialogViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:dialogViewController];
            }
            else if([tab.type isEqualToString:@"ITEM"])
            {
                ItemViewController *itemViewController = [[ItemViewController alloc] initWithTab:tab delegate:
                    (id<ItemViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:itemViewController];
            }
            else if([tab.type isEqualToString:@"PLAQUE"])
            {
                PlaqueViewController *plaqueViewController = [[PlaqueViewController alloc] initWithTab:tab delegate:
                    (id<PlaqueViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:plaqueViewController];
            }
            else if([tab.type isEqualToString:@"WEB_PAGE"])
            {
                WebPageViewController *webPageViewController = [[WebPageViewController alloc] initWithTab:tab delegate:
                    (id<WebPageViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:webPageViewController];
            }
            if(vc) [viewControllersDict setObject:vc forKey:[NSNumber numberWithLong:tab.tab_id]];
        }

        if(viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]) [viewControllers addObject:viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]];
        else _ARIS_LOG_(@"ERROR: Tab from server could not be created. KeyString %ld should exist but does not have a matching VC", tab.tab_id);
    }

    if(self.view) [tableView reloadData];
}

- (ARISNavigationController *) firstViewController
{
  if(viewControllers.count < 1) return nil;
  return viewControllers[0];
}

- (void) leaveGameButtonTouched
{
    [_MODEL_ leaveGame];
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
    return viewControllers.count;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  GamePlayTabSelectorCell *c;
  if(!(c = (GamePlayTabSelectorCell *)[tableView dequeueReusableCellWithIdentifier:[GamePlayTabSelectorCell cellIdentifier]]))
    c = [[GamePlayTabSelectorCell alloc] initWithDelegate:self];

  ARISNavigationController *anc = viewControllers[indexPath.row];
  id<GamePlayTabBarViewControllerProtocol> gptbvc = anc.viewControllers[0];

  [c setLabel:gptbvc.tabTitle];
  [c setIcon:gptbvc.tabIcon];

  return c;
}

- (void) requestDisplayTab:(Tab *)t
{
    Tab *tab;
    ARISNavigationController *vc;

    for(long i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if(tab == t)
        {
            if([tab.type isEqualToString:@"SCANNER"])
            {
                ARISNavigationController *navigation = (ARISNavigationController*)viewControllersDict[[NSNumber numberWithLong:tab.tab_id]];
                [((ScannerViewController *)navigation.topViewController) setPrompt:tab.info];
                // clean this up later.
                tab.info = @"";
            }
            else if([tab.type isEqualToString:@"AUGMENTED"])
            {
                ARISNavigationController *navigation = (ARISNavigationController*)viewControllersDict[[NSNumber numberWithLong:tab.tab_id]];
                int media_id = [tab.info intValue];
                if (media_id != 0) {
                    Media *m = [_MODEL_MEDIA_ mediaForId:media_id];
                    if (m) {
                        [((AugmentedViewController *)navigation.topViewController) setOverlay:m];
                    }
                }
                tab.info = @"";
            }
            else if([tab.type isEqualToString:@"DIALOG"])
            {
                DialogViewController *dialogViewController = [[DialogViewController alloc] initWithTab:tab delegate:
                    (id<DialogViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:dialogViewController];
            }
            else if([tab.type isEqualToString:@"ITEM"])
            {
                ItemViewController *itemViewController = [[ItemViewController alloc] initWithTab:tab delegate:
                    (id<ItemViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:itemViewController];
            }
            else if([tab.type isEqualToString:@"PLAQUE"])
            {
                PlaqueViewController *plaqueViewController = [[PlaqueViewController alloc] initWithTab:tab delegate:
                    (id<PlaqueViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:plaqueViewController];
            }
            else if([tab.type isEqualToString:@"WEB_PAGE"])
            {
                WebPageViewController *webPageViewController = [[WebPageViewController alloc] initWithTab:tab delegate:
                    (id<WebPageViewControllerDelegate>)delegate];
                vc = [[ARISNavigationController alloc] initWithRootViewController:webPageViewController];
            }

            if(vc) //new vc was created- replace old one
            {
              for(long i = 0; i < viewControllers.count; i++)
              {
                if(viewControllers[i] == viewControllersDict[[NSNumber numberWithLong:tab.tab_id]])
                {
                  [viewControllersDict setObject:vc forKey:[NSNumber numberWithLong:tab.tab_id]];
                  [viewControllers setObject:vc atIndexedSubscript:(NSUInteger)i];
                }
              }
            }

            [delegate viewControllerRequestedDisplay:viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]];
            return;
        }
    }

    /*
    //Check by name
    for(long i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if([[tab.name lowercaseString] isEqualToString:[t lowercaseString]])
        {
            [delegate viewControllerRequestedDisplay:viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]];
            return;
        }
    }
    //Check by type
    for(long i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if([[tab.type lowercaseString] isEqualToString:[t lowercaseString]])
        {
            [delegate viewControllerRequestedDisplay:viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]];
            return;
        }
    }
     */
}

- (void) requestDisplayScannerWithPrompt:(NSString *)p
{
    Tab *tab;
    for(long i = 0; i < playerTabs.count; i++)
    {
        tab = playerTabs[i];
        if([tab.type isEqualToString:@"SCANNER"])
        {
            [((ScannerViewController *)viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]) setPrompt:p];
            [delegate viewControllerRequestedDisplay:viewControllersDict[[NSNumber numberWithLong:tab.tab_id]]];
            return;
        }
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Tab *tab = playerTabs[indexPath.row];
  [self requestDisplayTab:tab];
}

- (void) refreshTabTable
{
    [tableView reloadData];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

