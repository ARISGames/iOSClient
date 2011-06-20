//
//  Panoramic.m
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Panoramic.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "PanoramicViewController.h"

@implementation Panoramic
@synthesize name,description,mediaId,iconMediaId,alignMediaId,kind,panoramicId;
-(nearbyObjectKind) kind { return NearbyObjectPanoramic; }

- (Panoramic *) init {
    self = [super init];
    if (self) {
		kind = NearbyObjectPanoramic;
        iconMediaId = 5;
    }
    return self;	
}



- (void) display{
	NSLog(@"Panoramic: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	PanoramicViewController *panoramicViewController = [[PanoramicViewController alloc] initWithNibName:@"PanoramicViewController" bundle: [NSBundle mainBundle]];
	panoramicViewController.panoramic = self;
	[appDelegate displayNearbyObjectView:panoramicViewController];
	[panoramicViewController release];
}



- (void) dealloc {
	[name release];
	[description release];
	[super dealloc];
}

- (NSString *) name {
    return self.name;
}

- (int)	iconMediaId {
    return 5; 
}

@end
