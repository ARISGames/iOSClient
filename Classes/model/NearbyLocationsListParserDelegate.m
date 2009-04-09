//
//  NearbyLocationsListParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NearbyLocationsListParserDelegate.h"
#import "NearbyLocation.h";

@implementation NearbyLocationsListParserDelegate

- (NearbyLocationsListParserDelegate*)initWithNearbyLocationsList:(NSMutableArray *)modelNearbyLocationList {
	self = [super init];
    if ( self ) {
		nearbyLocationList = modelNearbyLocationList;
		[nearbyLocationList retain];
    }
    return self;
}



#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	if(qName) {
		elementName = qName;
	}
	
	if ([elementName isEqualToString:@"nearbyLocation"]) {
		NearbyLocation *nearbyLocation = [[NearbyLocation alloc] init];
		nearbyLocation.locationId = [[attributeDict objectForKey:@"id"] intValue];
		nearbyLocation.name = [attributeDict objectForKey:@"label"];
		nearbyLocation.type = [attributeDict objectForKey:@"type"];
		nearbyLocation.iconURL = [attributeDict objectForKey:@"iconURL"];
		nearbyLocation.URL = [attributeDict objectForKey:@"URL"];
		[nearbyLocationList addObject:nearbyLocation];
		NSLog([NSString stringWithFormat:@"Nearby Location added to Model: %@ Type: %@ URL: %@", 
			   nearbyLocation.name, nearbyLocation.type, nearbyLocation.URL]);
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"Begin parsing nearby Locations");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"Done parsing nearby Locations");
	NSNotification *nearbyLocationListNotification = [NSNotification notificationWithName:@"ReceivedNearbyLocationList" object:nearbyLocationList];
	[[NSNotificationCenter defaultCenter] postNotification:nearbyLocationListNotification];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//nada
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//nada
}

- (void)dealloc {
	[nearbyLocationList release];
    [super dealloc];
}




@end
