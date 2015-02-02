//
//  ARISContainerViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 5/7/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@interface ARISContainerViewController : ARISViewController
{
    UIViewController *currentChildViewController;
}

- (void) displayContentController:(UIViewController*)content;

@end
