//
//  ARISGamePlayTabBarViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/8/13.
//
//

#import "ARISGamePlayTabBarViewController.h"

@interface ARISGamePlayTabBarViewController()

@end

@implementation ARISGamePlayTabBarViewController

@synthesize tabID;

- (id) init
{
    if([super init])
    {
        [self initialize];
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    badgeCount = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearBadge) name:@"ClearBadgeRequest" object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self clearBadge];
    self.tabBarController.selectedIndex = [self.tabBarController.viewControllers indexOfObjectIdenticalTo:self];
}

- (void) clearBadge
{
    badgeCount = 0;
    self.tabBarItem.badgeValue = nil;
}

- (void) incrementBadge
{
    badgeCount++;
    if(self.tabBarController.tabBar.selectedItem == self.tabBarItem) badgeCount = 0;
    if(badgeCount != 0) self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
