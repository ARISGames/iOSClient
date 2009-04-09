//
//  NearbyLocationsListParserDelegate.h
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NearbyLocationsListParserDelegate : NSObject {
	NSMutableArray *nearbyLocationList;
}

- (NearbyLocationsListParserDelegate*)initWithNearbyLocationsList:(NSMutableArray *)modelNearbyLocationsList;

@end