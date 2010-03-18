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

-(void) setMessage: (NSString*) newMessage{
	label.text = newMessage;
	[label setNeedsDisplay];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"Waiting Indicator: ViewDidLoad");
	[spinner startAnimating];
	
	//should force a display
	[self.view drawRect:self.view.bounds];

	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	NSLog(@"Waiting Indicator: Dealloc");
    [super dealloc];
}


@end
