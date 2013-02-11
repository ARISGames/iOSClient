//
//  ARISMoviePlayerViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/22/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISMoviePlayerViewController.h"
#import "RootViewController.h"

@implementation ARISMoviePlayerViewController
@synthesize mediaPlaybackButton;

- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor blackColor];
	[super viewDidLoad];
}

-(void) viewDidDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    UIApplication* application = [UIApplication sharedApplication];
    if (application.statusBarOrientation != UIInterfaceOrientationPortrait){
        UIViewController *c = [[UIViewController alloc]init];
        [[RootViewController sharedRootViewController] presentModalViewController:c animated:NO];
        [[RootViewController sharedRootViewController] dismissModalViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"MovieForcedRotationToPortrait" object:nil]];
    } 
    [RootViewController sharedRootViewController].nearbyObjectNavigationController.view.frame = [RootViewController sharedRootViewController].gamePlayTabBarController.view.bounds;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end