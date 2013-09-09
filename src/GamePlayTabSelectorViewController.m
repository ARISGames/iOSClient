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
#import "UIColor+ARISColors.h"

@interface GamePlayTabSelectorViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UIView *leaveGameButton;
    NSMutableArray *viewControllers;
    
    BOOL hasAppeared;
    id<GamePlayTabSelectorViewControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *leaveGameButton;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@end

@implementation GamePlayTabSelectorViewController
@synthesize tableView;
@synthesize leaveGameButton;
@synthesize viewControllers;

- (id) initWithViewControllers:(NSMutableArray *)vcs delegate:(id<GamePlayTabSelectorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        hasAppeared = NO;
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
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor ARISColorSideNaviagtionBackdrop];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    
    self.tableView.frame = self.view.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(20,0,0,0);
    [self.view addSubview:self.tableView];
    
    if(![AppModel sharedAppModel].disableLeaveGame)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(20,0,44,0);
        
        self.leaveGameButton = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44)];
        UILabel *leaveGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,0,self.view.bounds.size.width-30,44)];
        leaveGameLabel.textAlignment = NSTextAlignmentLeft;
        leaveGameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        leaveGameLabel.text = @"Leave Game";
        leaveGameLabel.textColor = [UIColor ARISColorText];
        UIImageView *leaveGameArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowBack"]];
        leaveGameArrow.frame = CGRectMake(6,13,19,19);
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
        line.backgroundColor = [UIColor ARISColorLightGray];
        [self.leaveGameButton addSubview:line];
        [self.leaveGameButton addSubview:leaveGameLabel];
        [self.leaveGameButton addSubview:leaveGameArrow];
        self.leaveGameButton.userInteractionEnabled = YES;
        self.leaveGameButton.backgroundColor = [UIColor ARISColorTextBackdrop];
        self.leaveGameButton.opaque = NO;
        [self.leaveGameButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveGameButtonTouched)]];
        
        [self.view addSubview:self.leaveGameButton];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (void) leaveGameButtonTouched
{
    [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) stopAudio];
    [delegate gameRequestsDismissal];
}

- (ARISGamePlayTabBarViewController *) tabBarVCFromNavC:(ARISNavigationController *)anc
{
    if(![anc isKindOfClass:[ARISNavigationController class]]) return nil;
    if([[anc.viewControllers objectAtIndex:0] isKindOfClass:[ARISGamePlayTabBarViewController class]])
        return (ARISGamePlayTabBarViewController *)[anc.viewControllers objectAtIndex:0];
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewControllers count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:nil];
    c.opaque = NO;
    c.backgroundColor = [UIColor clearColor];
    c.textLabel.textColor = [UIColor ARISColorSideNaviagtionText];
    UIViewController *vc = [self.viewControllers objectAtIndex:indexPath.row];
    ARISNavigationController *anc = (ARISNavigationController *)vc;
    ARISGamePlayTabBarViewController *agptbvc = [anc.viewControllers objectAtIndex:0];
    c.textLabel.text = agptbvc.tabID;
    
    return c;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate viewControllerRequestedDisplay:[self.viewControllers objectAtIndex:indexPath.row]];
}

@end
