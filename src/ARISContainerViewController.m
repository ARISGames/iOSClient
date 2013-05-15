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
    //Frame will need to get set in viewWillAppear:
    // http://stackoverflow.com/questions/11305818/create-view-in-load-view-and-set-its-frame-but-frame-auto-changes
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGRect) screenRect //This is Stupid. 
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    return rect;
}

- (void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIDeviceOrientationPortrait animated:NO];
    self.view.frame = [self screenRect];
}

// Container VC Functions pulled from Apple Docs 5/6/13
// http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/CreatingCustomContainerViewControllers/CreatingCustomContainerViewControllers.html
- (void) displayContentController:(UIViewController*)content
{
    if(currentChildViewController) [self hideContentController:currentChildViewController];
    
    [self addChildViewController:content];
    content.view.frame = [self screenRect];
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end
