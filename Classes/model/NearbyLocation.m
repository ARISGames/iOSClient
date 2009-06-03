//
//  NearbyLocation.m
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NearbyLocation.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "GenericWebViewController.h"

@implementation NearbyLocation

@synthesize name;
@synthesize kind;
@synthesize forcedDisplay;

@synthesize locationId;
@synthesize iconURL;
@synthesize URL;

- (void) display{
	NSLog(@"NearbyLocation (Web Style): Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	//Set up a GenericWebViewController
	GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] 
														  initWithNibName:@"GenericWebView" bundle:[NSBundle mainBundle]];	
	NSString *baseURL = [appModel getURLStringForModule:@"RESTNodeViewer"];
	NSString *URLparams = self.URL;
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	[genericWebViewController setModel:appModel];
	[genericWebViewController setURL: fullURL];
	genericWebViewController.title = self.name;

	//Have AppDelegate display
	[appDelegate displayNearbyObjectView:genericWebViewController];
}


- (void)dealloc {
	[name release];
	[iconURL release];
	[URL release];
    [super dealloc];
}

@end
