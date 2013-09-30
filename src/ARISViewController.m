//
//  ARISViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/30/13.
//
//

#import "ARISViewController.h"

@interface ARISViewController ()
{
    BOOL willAppearFirstTime;
    BOOL didAppearFirstTime; 
}
@end

@implementation ARISViewController

- (void) initialize
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    willAppearFirstTime = NO;
    didAppearFirstTime = NO; 
}

- (id) init
{
    if(self = [super init])
    {
        [self initialize];
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!willAppearFirstTime) { [self viewWillAppearFirstTime:animated]; willAppearFirstTime = YES; }
}

- (void) viewWillAppearFirstTime:(BOOL)animated
{
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!didAppearFirstTime) { [self viewDidAppearFirstTime:animated]; didAppearFirstTime = YES; }
}

- (void) viewDidAppearFirstTime:(BOOL)animated
{
}

/*
- (NSUInteger) supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationPortrait;
}
 */

@end
