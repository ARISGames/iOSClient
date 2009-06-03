//
//  WaitingIndicatorViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WaitingIndicatorViewController.h"

@implementation WaitingIndicatorViewController
@synthesize spinner;
@synthesize label;
@synthesize message;

-(void)setMessage {
	label.text = message;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [spinner startAnimating];
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
