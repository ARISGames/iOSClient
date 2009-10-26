//
//  LocationListParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LocationListParserDelegate.h"
#import "Location.h";
#import "Player.h";

@implementation LocationListParserDelegate

- (LocationListParserDelegate*)initWithModel:(AppModel *)model{
	self = [super init];
    if ( self ) {
		locationList = model.locationList;
		[locationList  retain];
		playerList = model.playerList;
		[playerList retain];
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
	
	if ([elementName isEqualToString:@"location"]) {
		//Found a location element 
		Location *location = [[Location alloc] init];
		location.locationId = [[attributeDict objectForKey:@"location_id"] intValue];
		location.name = [attributeDict objectForKey:@"name"];
		location.latitude = [[attributeDict objectForKey:@"latitude"] doubleValue];
		location.longitude = [[attributeDict objectForKey:@"longitude"] doubleValue];
		if ([[attributeDict objectForKey:@"hidden"] isEqualToString: @"1"]) location.hidden = YES;
		else location.hidden = NO;
		location.qty = [[attributeDict objectForKey:@"qty"] intValue];
		
		[locationList addObject:location];
		NSLog([NSString stringWithFormat:@"Adding Location: %@", location.name]);
	}
	
	if ([elementName isEqualToString:@"player"]) {
		//Found a location element 
		Player *player = [[Player alloc] init];
		player.name = [attributeDict objectForKey:@"name"];
		player.latitude = [[attributeDict objectForKey:@"latitude"] doubleValue];
		player.longitude = [[attributeDict objectForKey:@"longitude"] doubleValue];
		player.hidden = NO;
		
		[playerList addObject:player];
		NSLog([NSString stringWithFormat:@"Adding Player: %@", player.name]);
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"Begin Parsing Location XML");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:locationList forKey:@"locationList"];
	NSLog(@"Finished Parsing Location XML");
	NSNotification *locationListNotification = [NSNotification notificationWithName:@"ReceivedLocationList" object:self userInfo:dictionary];
	[[NSNotificationCenter defaultCenter] postNotification:locationListNotification];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//nada
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//nada
}

- (void)dealloc {
	[locationList release];
    [super dealloc];
}

@end
