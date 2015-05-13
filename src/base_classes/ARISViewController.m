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
}
@end

@implementation ARISViewController

- (void) initialize
{
    self.automaticallyAdjustsScrollViewInsets = NO;
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

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
