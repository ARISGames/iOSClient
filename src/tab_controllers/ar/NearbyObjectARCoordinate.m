//
//  NearbyObjectARCoordinate.m
//  ARIS
//
//  Created by David J Gagnon on 12/6/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NearbyObjectARCoordinate.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Location.h"


@implementation NearbyObjectARCoordinate

@synthesize mediaId;

+ (NearbyObjectARCoordinate *)coordinateWithNearbyLocation:(Location *)aNearbyLocation {
	
	NearbyObjectARCoordinate *newCoordinate = [[NearbyObjectARCoordinate alloc] init];
	
	//Let's try correcting for altitude
	NSLog(@"NearbyObjectARCoordinate: Initing a coord with altitude: %f",aNearbyLocation.latlon.altitude);
	
	CLLocationCoordinate2D adjustedLocationCoordinate2D;
	adjustedLocationCoordinate2D.latitude = aNearbyLocation.latlon.coordinate.latitude;
	adjustedLocationCoordinate2D.longitude = aNearbyLocation.latlon.coordinate.longitude;
	
	float adjustedAltitude = [AppModel sharedAppModel].player.location.altitude - 10;
	NSLog(@"NearbyObjectARCoordinate: Adjusted Altitude: %f",adjustedAltitude);
	
	CLLocation *tempLocation = [[CLLocation alloc] initWithCoordinate: adjustedLocationCoordinate2D altitude: adjustedAltitude horizontalAccuracy:1.0 verticalAccuracy:1.0 timestamp:[NSDate date]];

	
	//Carry on with the normal stuff
	newCoordinate.geoLocation = tempLocation;
	newCoordinate.title = aNearbyLocation.name;
	newCoordinate.mediaId = aNearbyLocation.gameObject.iconMediaId;
	
	return newCoordinate;		
}
	
	
@end
