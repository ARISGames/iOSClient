//
//  QRScannerParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QRScannerParserDelegate.h"

#import "QRCode.h"
#import "Item.h"


@implementation QRScannerParserDelegate

@synthesize delegate;
@synthesize qrcode;


#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	if(qName) {
		elementName = qName;
	}
	
	if ( [elementName isEqualToString:@"QRCode"]) {
		//Found a QR element 
		QRCode *currentObject = [[QRCode alloc] init];
		currentObject.name = [attributeDict objectForKey:@"name"];
		currentObject.URL =  [attributeDict objectForKey:@"URL"];
		currentObject.iconURL = [attributeDict objectForKey:@"iconURL"];
		qrcode = currentObject;
		NSLog(@"QRScannerParserDelegate: QRCode found : '%@'", currentObject.name);
	}
	else if ( [elementName isEqualToString:@"Item"])  {
		Item *currentObject = [[Item alloc] init];	
		
		currentObject.itemId = [attributeDict objectForKey:@"id"];
		currentObject.name = [attributeDict objectForKey:@"name"];
		currentObject.type = [attributeDict objectForKey:@"itemType"];
		currentObject.description = [attributeDict objectForKey:@"description"];
		currentObject.mediaURL = [attributeDict objectForKey:@"mediaURL"];
		currentObject.iconURL = [attributeDict objectForKey:@"iconURL"];
		qrcode = currentObject;
		NSLog(@"QRScannerParserDelegate: Item found : '%@'", currentObject.name);

	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"Begin Parsing QR XML");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"QRScannerParserDelegate: Finished Parsing QR XML, notifying delegate");
	if(self.delegate != NULL && [[self delegate] respondsToSelector:@selector(qrParserDidFinish:)]) {
		[[self delegate] qrParserDidFinish:qrcode];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//nada
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//nada
}
- (void)dealloc {
    [super dealloc];
}

@end
