//
//  ARISNavigationController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/16/13.
//
//

#import "ARISNavigationController.h"

@implementation ARISNavigationController

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else {
        return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}
@end
