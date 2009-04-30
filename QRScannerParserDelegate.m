//
//  QRScannerParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QRScannerParserDelegate.h"


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
	
	if ([elementName isEqualToString:@"QRCode"]) {
		//Found a location element 
		qrcode = [[QRCode alloc]init];
		qrcode.label = [attributeDict objectForKey:@"label"];
		qrcode.type = [attributeDict objectForKey:@"type"];
		qrcode.URL = [attributeDict objectForKey:@"url"];
		qrcode.iconURL = [attributeDict objectForKey:@"icon"];

		NSLog([NSString stringWithFormat:@"QRScannerParserDelegate: Recieved QR Code details for '%@'", qrcode.label]);
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
