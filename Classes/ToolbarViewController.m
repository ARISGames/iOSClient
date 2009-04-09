//
//  ToolbarViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AudioToolbox/AudioToolbox.h"
#import "ToolbarViewController.h"


@implementation ToolbarViewController

@synthesize titleLabel;
@synthesize navigationItem;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//register for notifications from views
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(processNearbyLocationsList:) name:@"ReceivedNearbyLocationList" object:nil];
	
	NSLog(@"Top Toolbar Loaded");
}

-(void) setToolbarTitle:(NSString *)title {
	//NSLog(@"setToolbarTitle");
	titleLabel.text = title;
}


- (void)processNearbyLocationsList:(NSNotification *)notification {
    NSLog(@"Toolbar recieved Nearby Locations List Notification");
		
	//Clear a button if it exists
	navigationItem.rightBarButtonItem = nil;
	
	if ([notification.object count] > 0) {
		
		//Determine the Button Label
		NSString *label;
		if ([notification.object count] == 1) {
			NearbyLocation *loc = [notification.object objectAtIndex:0];
			label = loc.name; 
		}
		else label = @"Nearby"; 
		
		//Create the Button
		UIBarButtonItem *nearbyButton = [[UIBarButtonItem alloc] initWithTitle: label style:UIBarButtonSystemItemEdit target:self action:@selector(nearbyButtonAction:)];
		navigationItem.rightBarButtonItem = nearbyButton;
		[nearbyButton release];
		
		//Vibrate
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
		
	}//if
}

- (void)nearbyButtonAction:(id)sender {
	NSLog(@"Nearby Button Touched");
	NSNotification *notification = [NSNotification notificationWithName:@"NearbyButtonTouched" object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)nearbyViewBackButtonAction:(id)sender {
	NSLog(@"Nearby View Back Button Touched");
	NSNotification *notification = [NSNotification notificationWithName:@"NearbyViewBackButtonTouched" object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[titleLabel release];
    [super dealloc];
}


@end
