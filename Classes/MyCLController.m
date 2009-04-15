/*
 
 File: MyCLController.m
 Abstract: Singleton class used to talk to CoreLocation and send results back to
 the app's view controllers.
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */
#import "MyCLController.h"

// Shorthand for getting localized strings, used in formats below for readability
#define LocStr(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]


@implementation MyCLController

@synthesize locationManager;

- (MyCLController*) initWithAppModel:(AppModel *)model {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // Tells the location manager to send updates to this object
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.locationManager.distanceFilter = 1.0; //Minimum change of 1 meters for update
	}
	appModel = model;
	return self;
		
}


// Called when the location is updated
	- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	NSLog(@"Read %lf, %lf from CLLocationManager with Accuracy of %gm,%gm", newLocation.coordinate.latitude,
		  newLocation.coordinate.longitude,  newLocation.horizontalAccuracy, newLocation.verticalAccuracy );
	
	//Update the Model
		appModel.lastLocation = newLocation;
		
	//Tell the other parts of the client
	NSNotification *updatedLocationNotification = [NSNotification notificationWithName:@"PlayerMoved" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:updatedLocationNotification];
		
	//Tell the model to update the server and fetch any nearby locations
	[appModel updateServerLocationAndfetchNearbyLocationList];
	
}
/*
 - (void)locationManager:(CLLocationManager *)manager
 didUpdateToLocation:(CLLocation *)newLocation
 fromLocation:(CLLocation *)oldLocation
 {
 NSMutableString *update = [[[NSMutableString alloc] init] autorelease];
 
 // Timestamp
 NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
 [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
 [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
 [update appendFormat:@"%@\n\n", [dateFormatter stringFromDate:newLocation.timestamp]];
 
 // Horizontal coordinates
 if (signbit(newLocation.horizontalAccuracy)) {
 // Negative accuracy means an invalid or unavailable measurement
 [update appendString:LocStr(@"LatLongUnavailable")];
 } else {
 // CoreLocation returns positive for North & East, negative for South & West
 [update appendFormat:LocStr(@"LatLongFormat"), // This format takes 4 args: 2 pairs of the form coordinate + compass direction
 fabs(newLocation.coordinate.latitude), signbit(newLocation.coordinate.latitude) ? LocStr(@"South") : LocStr(@"North"),
 fabs(newLocation.coordinate.longitude),	signbit(newLocation.coordinate.longitude) ? LocStr(@"West") : LocStr(@"East")];
 [update appendString:@"\n"];
 [update appendFormat:LocStr(@"MeterAccuracyFormat"), newLocation.horizontalAccuracy];
 }
 [update appendString:@"\n\n"];
 
 // Altitude
 if (signbit(newLocation.verticalAccuracy)) {
 // Negative accuracy means an invalid or unavailable measurement
 [update appendString:LocStr(@"AltUnavailable")];
 } else {
 // Positive and negative in altitude denote above & below sea level, respectively
 [update appendFormat:LocStr(@"AltitudeFormat"), fabs(newLocation.altitude),	(signbit(newLocation.altitude)) ? LocStr(@"BelowSeaLevel") : LocStr(@"AboveSeaLevel")];
 [update appendString:@"\n"];
 [update appendFormat:LocStr(@"MeterAccuracyFormat"), newLocation.verticalAccuracy];
 }
 [update appendString:@"\n\n"];
 
 // Calculate disatance moved and time elapsed, but only if we have an "old" location
 //
 // NOTE: Timestamps are based on when queries start, not when they return. CoreLocation will query your
 // location based on several methods. Sometimes, queries can come back in a different order from which
 // they were placed, which means the timestamp on the "old" location can sometimes be newer than on the
 // "new" location. For the example, we will clamp the timeElapsed to zero to avoid showing negative times
 // in the UI.
 //
 if (oldLocation != nil) {
 CLLocationDistance distanceMoved = [newLocation getDistanceFrom:oldLocation];
 NSTimeInterval timeElapsed = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
 
 [update appendFormat:LocStr(@"LocationChangedFormat"), distanceMoved];
 if (signbit(timeElapsed)) {
 [update appendString:LocStr(@"FromPreviousMeasurement")];
 } else {
 [update appendFormat:LocStr(@"TimeElapsedFormat"), timeElapsed];
 }
 [update appendString:@"\n\n"];
 }
 
 // Send the update to our delegate
 [self.delegate newLocationUpdate:update];
 }
 */

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	NSMutableString *errorString = [[[NSMutableString alloc] init] autorelease];
	
	if ([error domain] == kCLErrorDomain) {
		
		// We handle CoreLocation-related errors here
		
		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
				//
			case kCLErrorDenied:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
				//
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	} else {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
	
	//Send the update somewhere?
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
	[locationManager release];
    [super dealloc];
}

@end