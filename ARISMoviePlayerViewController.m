//
//  ARISMoviePlayerViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/22/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISMoviePlayerViewController.h"

@implementation ARISMoviePlayerViewController
@synthesize mediaPlaybackButton;
- (void)viewDidLoad
{
	self.view.backgroundColor = [UIColor blackColor];
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	/*
	if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
	   || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
		return YES;
	else if((interfaceOrientation == UIInterfaceOrientationPortrait)
			|| (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
		return NO;
	 */
	return YES;
}

@end