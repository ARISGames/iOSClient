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
@synthesize name,description,media,iconMediaId,alignMediaId,kind,panoramicId,textureArray,locationId;
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
    
	PanoramicViewController *panoramicViewController = [[PanoramicViewController alloc] initWithNibName:@"PanoramicViewController" bundle: [NSBundle mainBundle]];
	panoramicViewController.panoramic = self;
	[[RootViewController sharedRootViewController] displayNearbyObjectView:panoramicViewController];
}




@end
