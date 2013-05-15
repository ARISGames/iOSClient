//
//  ARISContainerViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 5/7/13.
//
//

#import <UIKit/UIKit.h>

@interface ARISContainerViewController : UIViewController
{
    UIViewController *currentChildViewController;
}

- (void) displayContentController:(UIViewController*)content;

@end
