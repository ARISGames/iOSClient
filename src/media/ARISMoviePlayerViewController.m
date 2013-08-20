//
//  ARISMoviePlayerViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/22/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISMoviePlayerViewController.h"
#import "RootViewController.h"
#import "UIColor+ARISColors.h"

@implementation ARISMoviePlayerViewController

- (void)viewDidLoad
{
	self.view.backgroundColor = [UIColor ARISColorViewBackdrop];
	[super viewDidLoad];
}

-(void) viewDidDisappear:(BOOL)animated
{
    UIApplication* application = [UIApplication sharedApplication];
    if(application.statusBarOrientation != UIInterfaceOrientationPortrait)
    {
        NSLog(@"NSNotification: MovieForcedRotationToPortrait");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"MovieForcedRotationToPortrait" object:nil]];
    } 
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end