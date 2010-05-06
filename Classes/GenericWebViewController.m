//
//  GenericWebViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/19/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "GenericWebViewController.h"
#import "ARISAppDelegate.h"


@implementation GenericWebViewController
@synthesize appModel, webview;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget: (ARISAppDelegate *)[[UIApplication sharedApplication] delegate] withObject: @"Loading..."];
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showWaitingIndicator:@"Loading..." displayProgressBar:NO];

	appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
	
	webview.delegate = self;	
	webview.hidden = YES;
	[webview loadRequest:request];
	
	NSLog(@"GenericWebViewController: is Now Loading the URL in ViewDidLoad");
	NSLog(@"GenericWebViewController: view loaded");
	
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}
 

#pragma mark custom methods and logic
-(void) setURL: (NSString*)urlString {
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget: (ARISAppDelegate *)[[UIApplication sharedApplication] delegate] withObject: @"Loading..."];	
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showWaitingIndicator:@"Loading..." displayProgressBar:NO];
	/*
	request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	webview.hidden = YES;
	[webview loadRequest:request];
	NSLog(@"Generic Web Controller is Now Loading: %@",urlString);
	 */
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
	webview.hidden = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//Stop Waiting Indicator
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	webview.hidden = NO;
	
	//Display an error message to user about the connection
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];
	
	//Stop Waiting Indicator
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
}

@end
