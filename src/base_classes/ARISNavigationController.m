//
//  ARISNavigationController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/16/13.
//
//

#import "ARISNavigationController.h"

@implementation ARISNavigationController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
  return [self.topViewController supportedInterfaceOrientations];
}
- (BOOL) shouldAutorotate
{
  return [self.topViewController shouldAutorotate];
}

@end
