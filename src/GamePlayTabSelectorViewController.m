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
    self.view.backgroundColor = [ARISTemplate ARISColorSideNaviagtionBackdrop];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    
    self.tableView.frame = self.view.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(64,0,0,0);
    [self.view addSubview:self.tableView];
    
    if(![AppModel sharedAppModel].disableLeaveGame)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(64,0,44,0);
        
        self.leaveGameButton = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44)];
        UILabel *leaveGameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,0,self.view.bounds.size.width-30,44)];
        leaveGameLabel.textAlignment = NSTextAlignmentLeft;
        leaveGameLabel.font = [ARISTemplate ARISButtonFont];
        leaveGameLabel.text = @"Leave Game";
        leaveGameLabel.textColor = [ARISTemplate ARISColorText];
        UIImageView *leaveGameArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowBack"]];
        leaveGameLabel.accessibilityLabel = @"Leave Game";
        leaveGameArrow.frame = CGRectMake(6,13,19,19);
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
        line.backgroundColor = [UIColor ARISColorLightGray];
        [self.leaveGameButton addSubview:line];
        [self.leaveGameButton addSubview:leaveGameLabel];
        [self.leaveGameButton addSubview:leaveGameArrow];
        self.leaveGameButton.userInteractionEnabled = YES;
        self.leaveGameButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
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


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"TOOLS";
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    c.opaque = NO;
    c.backgroundColor = [UIColor clearColor];
    c.textLabel.textColor = [ARISTemplate ARISColorSideNaviagtionText];
    
    ARISNavigationController *anc = (ARISNavigationController *)[self.viewControllers objectAtIndex:indexPath.row];
    ARISGamePlayTabBarViewController *agptbvc = [anc.viewControllers objectAtIndex:0];
    
    while([c.contentView.subviews count] > 0)
        [[c.contentView.subviews objectAtIndex:0] removeFromSuperview];
    
    c.textLabel.text = agptbvc.title;
    c.imageView.image = [UIImage imageNamed:agptbvc.tabIconName];
    
    return c;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate viewControllerRequestedDisplay:[self.viewControllers objectAtIndex:indexPath.row]];
}

- (void) dealloc
{
    
}

@end
