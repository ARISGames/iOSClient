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
    NSArray *viewControllers;
    id<GamePlayTabSelectorViewControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *viewControllers;
@end

@implementation GamePlayTabSelectorViewController
@synthesize tableView;
@synthesize viewControllers;

- (id) initWithViewControllers:(NSArray *)vcs delegate:(id<GamePlayTabSelectorViewControllerDelegate>)d
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewControllers count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:nil];
    UIViewController *vc = [self.viewControllers objectAtIndex:indexPath.row];
    if([vc isKindOfClass:[BogusSelectGameViewController class]])
    {
        c.textLabel.text = @"LEAVE";
    }
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
