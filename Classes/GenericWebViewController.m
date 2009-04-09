//
//  GenericWebViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/19/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GenericWebViewController.h"


@implementation GenericWebViewController

@synthesize webview;
@synthesize titleLabel;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[webview loadRequest:request];
	NSLog(@"Generic Web Controller is Now Loading the URL in ViewDidLoad");
	NSLog(@"GenericWebView loaded");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)backButtonAction:(id)sender {
	NSLog(@"Back Button Touched");
	NSNotification *loginNotification = [NSNotification notificationWithName:@"BackButtonTouched" object:self];
	[[NSNotificationCenter defaultCenter] postNotification:loginNotification];
}


#pragma mark custom methods and logic
-(void) setURL: (NSString*)urlString {
	request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[webview loadRequest:request];
	NSLog(@"Generic Web Controller is Now Loading the URL in setURL");
}

-(void) setModel:(AppModel *)model{
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	NSLog(@"model set for GenericWebViewController");
}

-(void) setToolbarTitle:(NSString *)title {
	titleLabel.text = title;
}

- (void)dealloc {
	[appModel release];
    [super dealloc];
}


@end
