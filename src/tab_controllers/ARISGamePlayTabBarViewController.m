//
//  ARISGamePlayTabBarViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/8/13.
//
//

#import "ARISGamePlayTabBarViewController.h"

@interface ARISGamePlayTabBarViewController()
{
    id<GamePlayTabBarViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation ARISGamePlayTabBarViewController

@synthesize tabID;

- (id) init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate>)d
{
    if(self = [super init])
    {
        [self initialize];
        delegate = d;
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self initialize];
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<GamePlayTabBarViewControllerDelegate>)d
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self initialize];
        delegate = d;
    }
    return self;
}

- (void) initialize
{
    badgeCount = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearBadge) name:@"ClearBadgeRequest" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"259-list"] style: UIBarButtonItemStylePlain target:self action:@selector(showNav)];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self clearBadge];
}

- (void) clearBadge
{
    badgeCount = 0;
}

- (void) incrementBadge
{
    badgeCount++;
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
