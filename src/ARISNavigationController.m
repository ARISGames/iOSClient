//
//  ARISNavigationController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/16/13.
//
//

#import "ARISNavigationController.h"

@implementation ARISNavigationController

- (NSUInteger) supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return [self.topViewController supportedInterfaceOrientations];
}

@end
