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
#import "BogusSelectGameViewController.h"

@interface GamePlayTabSelectorViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSMutableArray *viewControllers;
    id<GamePlayTabSelectorViewControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@end

@implementation GamePlayTabSelectorViewController
@synthesize tableView;
@synthesize viewControllers;

- (id) initWithViewControllers:(NSMutableArray *)vcs delegate:(id<GamePlayTabSelectorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.viewControllers = vcs;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (ARISGamePlayTabBarViewController *) tabBarVCFromNavC:(ARISNavigationController *)anc
{
    if(![anc isKindOfClass:[ARISNavigationController class]]) return nil;
    if([[anc.viewControllers objectAtIndex:0] isKindOfClass:[ARISGamePlayTabBarViewController class]])
        return (ARISGamePlayTabBarViewController *)[anc.viewControllers objectAtIndex:0];
    return nil;
}

- (void) addViewController:(UIViewController *)vc
{
    BOOL exists = NO;
    ARISGamePlayTabBarViewController *new = [self tabBarVCFromNavC:(ARISNavigationController *)vc];
    ARISGamePlayTabBarViewController *current;
    for(int i = 0; i < [self.viewControllers count]; i++)
    {
        current = [self tabBarVCFromNavC:[self.viewControllers objectAtIndex:i]];
        if([current.tabID isEqualToString:new.tabID])
            exists = YES;
    }
    if(!exists)
    {
        [self.viewControllers addObject:vc];
        [self.tableView reloadData];
    }
}

- (void) removeViewControllerWithTabID:(NSString *)t
{
    ARISGamePlayTabBarViewController *current;
    for(int i = 0; i < [self.viewControllers count]; i++)
    {
        current = [self tabBarVCFromNavC:[self.viewControllers objectAtIndex:i]];
        if([current.tabID isEqualToString:t])
        {
            [self.viewControllers removeObject:[self.viewControllers objectAtIndex:i]];
            [self.tableView reloadData];
            break;
        }
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewControllers count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:nil];
    UIViewController *vc = [self.viewControllers objectAtIndex:indexPath.row];
    if([vc isKindOfClass:[BogusSelectGameViewController class]])
        c.textLabel.text = @"LEAVE";
    else
    {
        ARISNavigationController *anc = (ARISNavigationController *)vc;
        ARISGamePlayTabBarViewController *agptbvc = [anc.viewControllers objectAtIndex:0];
        c.textLabel.text = agptbvc.tabID;
    }
    return c;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate viewControllerRequestedDisplay:[self.viewControllers objectAtIndex:indexPath.row]];
}

@end
