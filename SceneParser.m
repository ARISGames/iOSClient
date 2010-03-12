//
//  SceneParser.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "SceneParser.h"

const NSInteger kDefaultPc = 0;

NSString *const kTagPc = @"pc";
NSString *const kTagNpc = @"npc";
NSString *const kTagId = @"id";

NSString *const kTagZoomX = @"zoomX";
NSString *const kTagZoomY = @"zoomY";
NSString *const kTagZoomWidth = @"zoomWidth";
NSString *const kTagZoomHeight = @"zoomHeight";

NSString *const kTagSoundBg = @"bgSound";
NSString *const kTagSoundFg = @"fgSound";

@implementation SceneParser
@synthesize delegate, script;

#pragma mark Init/dealloc
- (id) initWithDefaultNpcId:(NSInteger)anNpcId {
	if (self = [super init]) {
		defaultNpcId = anNpcId;
		currentText = [[NSMutableString alloc] init];
		parser = nil;
		sourceText = nil;
		script = [[NSMutableArray alloc] init];
		delegate = nil;
	}
	return self;
}

- (void) dealloc {
	[script release];
	[sourceText release];
	[currentText release];
	[parser release];
	[super dealloc];
}

#pragma mark XML Parsing
- (void) parseText:(NSString *)text {
	sourceText = [text retain];
	[script removeAllObjects];
	
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	[parser release];
	parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	
	[parser parse];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	NSLog(@"Started %@", elementName);
	if ([elementName isEqualToString:kTagPc]) {
		isPc = YES;
		if ([[attributeDict objectForKey:kTagId] respondsToSelector:@selector(intValue)]) {
			currentCharacterId = [[attributeDict objectForKey:kTagId] intValue];
		}
		else currentCharacterId = kDefaultPc;
	}
	else if ([elementName isEqualToString:kTagNpc]) {
		isPc = NO;
		if ([[attributeDict objectForKey:kTagId] respondsToSelector:@selector(intValue)]) {
			currentCharacterId = [[attributeDict objectForKey:kTagId] intValue];
		}
		else currentCharacterId = defaultNpcId;
	}
	
	zoomRect = CGRectMake(0, 0, 320, 460);
	zoomRect.origin.x = [attributeDict objectForKey:kTagZoomX]
		? [[attributeDict objectForKey:kTagZoomX] floatValue] : zoomRect.origin.x;
	zoomRect.origin.y = [attributeDict objectForKey:kTagZoomX]
		? [[attributeDict objectForKey:kTagZoomY] floatValue] : zoomRect.origin.y;
	zoomRect.size.width = [attributeDict objectForKey:kTagZoomX]
		? [[attributeDict objectForKey:kTagZoomWidth] floatValue] : zoomRect.size.width;
	zoomRect.size.height = [attributeDict objectForKey:kTagZoomX]
		? [[attributeDict objectForKey:kTagZoomHeight] floatValue] : zoomRect.size.height;
	
	fgSound = [attributeDict objectForKey:kTagSoundFg]
		? [[attributeDict objectForKey:kTagSoundFg] intValue] : kEmptySound;
	bgSound = [attributeDict objectForKey:kTagSoundBg]
		? [[attributeDict objectForKey:kTagSoundBg] intValue] : kEmptySound;

	[currentText setString:@""];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	NSLog(@"Ended %@", elementName);
	if ([elementName isEqualToString:kTagPc] 
		|| [elementName isEqualToString:kTagNpc])
	{
		Scene *newScene = [[Scene alloc] initWithText:currentText
											  andIsPc:isPc
										 andCharacter:currentCharacterId
											  andZoom:zoomRect
										withForeSound:fgSound
										 andBackSound:bgSound];
		[script addObject:newScene];
		[newScene release];
	}
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	// Not wrapped in CDATA, so hope for the best and add to it
	[currentText appendString:string];
	NSLog(@"WARNING: No CDATA used for %@", string);
}

- (void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	// Fond CDATA, so HTML should work.
	
	NSString *text = [[NSString alloc] initWithData:CDATABlock
										   encoding:NSUTF8StringEncoding];
	[currentText appendString:text];
	[text release];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"Ended.");
	if ([script count] == 0) {
		// No parsing happened; use raw text.
		Scene *defaultScene = [[Scene alloc] initWithText:sourceText
												  andIsPc:NO
											 andCharacter:defaultNpcId
												  andZoom:CGRectMake(0, 0, 320, 460)
											withForeSound:kEmptySound
											 andBackSound:kEmptySound];
		[script addObject:defaultScene];
		[defaultScene release];
	}
	
	[sourceText release];
	sourceText = nil;
	
	NSLog(@"Calling.");
	if (delegate) [delegate didFinishParsing];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Fatal error: %@", parseError);
}
@end
