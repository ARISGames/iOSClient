//
//  XMLParserDelegate.m
//  ARIS
//
//  Created by Kevin Harris on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XMLParserDelegate.h"

@implementation XMLParserDelegate

- (XMLParserDelegate*)initWithDictionary:(NSDictionary *)aDictionary 
							  andResults:(NSMutableArray *)theResults 
						 forNotification:(NSString *)name
{
	self = [super init];
    if ( self ) {
		elementDictionary = aDictionary;
		[elementDictionary retain];

		results = theResults;
		[results retain];
		
		notificationName = name;
		[notificationName retain];
    }
	
    return self;
}

#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
	if(qName) elementName = qName;

	NSLog(@"XMLParser: Parsing %@", elementName);
	NSDictionary *attributes = [elementDictionary objectForKey:elementName];
	if (!attributes) {
		NSLog(@"XMLParser: ERROR: Undefined key %@", elementName);
		return;
	}
	else if ([attributes isEqual:[NSNull null]]) return;
	
	id classType = [attributes objectForKey:@"__CLASS_NAME"];
	if (!classType) {
		NSLog(@"XMLParser: ERROR: No __CLASS_NAME defined for %@.", notificationName);
		return;
	}
	
	id result = [[classType alloc] init];
	for (NSString *attributeKey in attributes) {
		if ([attributeKey isEqualToString:@"__CLASS_NAME"]) continue;
		SEL selector = NSSelectorFromString([attributes objectForKey:attributeKey]);
		
		id value = [attributeDict objectForKey:attributeKey];
		if (!value) {
			NSLog(@"XMLParser: ERROR: %@: No value for %@ in %@", attributeKey, elementName, notificationName);
			continue;
		}
		[result performSelector:selector withObject:value];
	}
	[results addObject:result];
	NSLog(@"XMLParser: added object");
}

- (void)parserDidStartDocument:(NSXMLParser *)parser { }

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSDictionary *result = [NSDictionary dictionaryWithObject:results forKey:@"result"];
	NSLog(@"XMLParser: Finished parsing. Posted '%@' notification", notificationName);
	
	NSNotification *notification = 
		[NSNotification notificationWithName:notificationName 
									  object:self 
									userInfo:result];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName { }

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { }

- (void)dealloc {
	[elementDictionary release];
	[results release];
	[notificationName release];
    [super dealloc];
}

@end
