//
//  InventoryParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InventoryParserDelegate.h"
#import "Item.h";


@implementation InventoryParserDelegate
- (InventoryParserDelegate*)initWithInventory:(NSMutableArray *)modelInventory {
	self = [super init];
    if ( self ) {
		inventory = modelInventory;
		[inventory retain];
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
	
	if ([elementName isEqualToString:@"row"]) {
		Item *item = [[Item alloc] init];
		item.itemId = [attributeDict objectForKey:@"item_id"];
		item.name = [attributeDict objectForKey:@"name"];
		item.description = [attributeDict objectForKey:@"description"];
		item.type = [attributeDict objectForKey:@"type"];
		item.mediaURL = [attributeDict objectForKey:@"media"];
		item.iconURL = [attributeDict objectForKey:@"icon"];
		[inventory addObject:item];
		NSLog([NSString stringWithFormat:@"Inventory Item added to Model: %@ ID: %d Type: %@", item.name, item.itemId, item.type] );
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
			NSLog(@"Begin parsing Player Inventory");
}
			  
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:inventory forKey:@"gameList"];
	NSLog(@"Done Parsing Player Inventory");
	NSNotification *inventoryNotification = [NSNotification notificationWithName:@"ReceivedInventory" object:self userInfo:dictionary];
	[[NSNotificationCenter defaultCenter] postNotification:inventoryNotification];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//nada
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//nada
}

- (void)dealloc {
	[inventory release];
    [super dealloc];
}

@end
