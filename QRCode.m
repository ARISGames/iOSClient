//
//  QRCode.m
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QRCode.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "GenericWebViewController.h"


@implementation QRCode

@synthesize name;
@synthesize kind;
@synthesize URL;
@synthesize iconURL;


- (void) display{
	NSLog(@"QRCode (Web Style): Display Self Requested");
	
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

@end
