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

- (void) viewDidLoad
{
	self.view.backgroundColor = [UIColor ARISColorViewBackdrop];
	[super viewDidLoad];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
