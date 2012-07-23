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

-(void) viewWillAppear:(BOOL)animated{
    [RootViewController sharedRootViewController].isMovie = YES;  
 //   [[RootViewController sharedRootViewController] dismissNearbyObjectView:[RootViewController sharedRootViewController].nearbyObjectNavigationController.visibleViewController];
}


-(void) viewWillDisappear:(BOOL)animated{
        [RootViewController sharedRootViewController].isMovie = NO;
}

-(void) viewDidDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    UIApplication* application = [UIApplication sharedApplication];
    if (application.statusBarOrientation != UIInterfaceOrientationPortrait){
        UIViewController *c = [[UIViewController alloc]init];
        [[RootViewController sharedRootViewController] presentModalViewController:c animated:NO];
        [[RootViewController sharedRootViewController] dismissModalViewControllerAnimated:NO];
    } 
    [RootViewController sharedRootViewController].nearbyObjectNavigationController.view.frame = [RootViewController sharedRootViewController].tabBarController.view.bounds;
    [RootViewController sharedRootViewController].tabBarController.selectedViewController.view.frame = [RootViewController sharedRootViewController].tabBarController.view.bounds;
    NSArray *childViewControllers = [RootViewController sharedRootViewController].tabBarController.selectedViewController.childViewControllers;
    for(int i =0; i < [childViewControllers count]; i++){
    //   ((UIViewController*)[childViewControllers objectAtIndex:i]).view.frame = [RootViewController sharedRootViewController].tabBarController.view.frame;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end