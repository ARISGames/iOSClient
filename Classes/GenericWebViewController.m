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
@synthesize backButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	webview.delegate = self;
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
	
	//Refesh any parts of the model that might have been changed while using this view
	[appModel fetchLocationList];
	[appModel fetchInventory];
	
	[self.view removeFromSuperview];
}


#pragma mark custom methods and logic
-(void) setURL: (NSString*)urlString {
	request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[webview loadRequest:request];
	NSLog(@"Generic Web Controller is Now Loading: %@",urlString);
}

-(void) setModel:(AppModel *)model{
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	
	NSLog(@"model set for GenericWebViewController");
}

- (void)dealloc {
	[appModel release];
    [super dealloc];
}

#pragma mark WebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
}

@end
