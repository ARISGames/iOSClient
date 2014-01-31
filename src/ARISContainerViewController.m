//
//  ARISContainerViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/7/13.
//
//

#import "ARISContainerViewController.h"

@implementation ARISContainerViewController

- (id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

- (void) loadView
{
    [super loadView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //forces the frame to be in landscape mode, results in weird frame when changing orientations
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //self.view.frame = [UIScreen mainScreen].bounds;
}

// Container VC Functions pulled from Apple Docs 5/6/13
// http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/CreatingCustomContainerViewControllers/CreatingCustomContainerViewControllers.html
- (void) displayContentController:(UIViewController*)content
{
    if(currentChildViewController) [self hideContentController:currentChildViewController];
    
    [self addChildViewController:content];
    content.view.frame = self.view.bounds;
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self];
    
    currentChildViewController = content;
}

- (void) hideContentController:(UIViewController*)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
    
    currentChildViewController = nil;
}

//For when we decide to use animations to switch between children (currently not used)
- (void) cycleFromViewController:(UIViewController*)oldC toViewController:(UIViewController*)newC
{
    [oldC willMoveToParentViewController:nil];
    [self addChildViewController:newC];
    newC.view.frame = self.view.frame;
    CGRect endFrame = self.view.frame;
    [self transitionFromViewController:oldC
                      toViewController:newC
                              duration:0.25
                               options:0
                            animations:^() { newC.view.frame = oldC.view.frame; oldC.view.frame = endFrame; }
                            completion:^(BOOL finished) { [oldC removeFromParentViewController]; [newC didMoveToParentViewController:self]; }];
}

- (NSUInteger) supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return [currentChildViewController supportedInterfaceOrientations];
}

@end
