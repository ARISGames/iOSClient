//
//  NearbyLocationsListParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NearbyLocationsListParserDelegate.h"
#import "NearbyLocation.h";
#import "Item.h";

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
	
	//Parse the old Web style locations that simply link to a URL handled with HTML
	if ([elementName isEqualToString:@"nearbyLocation"]) {
		NearbyLocation *nearbyLocation = [[NearbyLocation alloc] init];
		nearbyLocation.forcedDisplay = [[attributeDict objectForKey:@"forceView"] boolValue];
		nearbyLocation.locationId = [[attributeDict objectForKey:@"id"] intValue];
		nearbyLocation.name = [attributeDict objectForKey:@"label"];
		if ([[attributeDict objectForKey:@"type"] isEqualToString: @"Npc"]) nearbyLocation.kind = NearbyObjectNPC;
		if ([[attributeDict objectForKey:@"type"] isEqualToString: @"Node"]) nearbyLocation.kind = NearbyObjectNode;
		nearbyLocation.iconURL = [attributeDict objectForKey:@"iconURL"];
		nearbyLocation.URL = [attributeDict objectForKey:@"URL"];
		[nearbyLocationList addObject:nearbyLocation];
		NSLog([NSString stringWithFormat:@"Nearby Location added to Model: %@ URL: %@", 
			   nearbyLocation.name, nearbyLocation.URL]);
	}
	//Parse any items
	if ([elementName isEqualToString:@"item"]) {
		Item *nearbyItem = [[Item alloc] init];
		nearbyItem.itemId = [attributeDict objectForKey:@"id"];
		nearbyItem.locationId = [attributeDict objectForKey:@"locationID"];
		nearbyItem.name = [attributeDict objectForKey:@"name"];
		nearbyItem.description = [attributeDict objectForKey:@"description"];		
		nearbyItem.type = [attributeDict objectForKey:@"type"];
		nearbyItem.forcedDisplay = [[attributeDict objectForKey:@"forceView"] boolValue];
		nearbyItem.iconURL = [attributeDict objectForKey:@"iconURL"];
		nearbyItem.mediaURL = [attributeDict objectForKey:@"mediaURL"];
		[nearbyLocationList addObject:nearbyItem];
		NSLog([NSString stringWithFormat:@"Nearby Item added to Model: %@ Type: %@ LocationId: %d URL: %@", 
			   nearbyItem.name, nearbyItem.type, nearbyItem.locationId, nearbyItem.mediaURL]);
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
