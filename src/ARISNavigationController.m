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
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
//    NSInteger mask = 0;
//    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
//    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
//    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
//    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
//    return mask;
    NSLog(@"JUSTIN topViewController: %@", [self.topViewController description]);
    return [self.topViewController supportedInterfaceOrientations];
}

@end
