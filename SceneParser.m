//
//  SceneParser.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "SceneParser.h"

const NSInteger kDefaultPc = 0;
const float kDefaultZoomTime = 1.0;

NSString *const kTagPc = @"pc";
NSString *const kTagNpc = @"npc";
NSString *const kTagDialog = @"dialog";
NSString *const kTagImageMediaId = @"imageMediaId";
NSString *const kTagBgSoundMediaId = @"bgSoundMediaId";
NSString *const kTagFgSoundMediaId = @"fgSoundMediaId";
NSString *const kTagExitToTab = @"exitToTab";
NSString *const kTagZoomX = @"zoomX";
NSString *const kTagZoomY = @"zoomY";
NSString *const kTagZoomWidth = @"zoomWidth";
NSString *const kTagZoomHeight = @"zoomHeight";
NSString *const kTagZoomTime = @"zoomTime";


@implementation SceneParser
@synthesize currentText, sourceText, exitToTabWithTitle, delegate, script;

#pragma mark Init/dealloc
- (id) initWithDefaultNpcId:(NSInteger)imageMediaId {
	if ((self = [super init])) {
		defaultImageMediaId = imageMediaId;
		self.currentText = [[NSMutableString alloc] init];
		parser = nil;
		self.sourceText = nil;
		self.script = [[NSMutableArray alloc] init];
		self.delegate = nil;
	}
	return self;
}

- (void) dealloc {
	[script release];
	[sourceText release];
	[currentText release];
	[parser release];
    [exitToTabWithTitle release];
	[super dealloc];
}

#pragma mark XML Parsing
- (void) parseText:(NSString *)text {
	self.sourceText = text;
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
	NSLog(@"SceneParser: Starting Element %@", elementName);
	
    if ([elementName isEqualToString:kTagPc]) isPc = YES;
	else if ([elementName isEqualToString:kTagNpc]) isPc = NO;
    else if ([elementName isEqualToString:kTagDialog]){
        exitToTabWithTitle = [attributeDict objectForKey:kTagExitToTab] ?
        [attributeDict objectForKey:kTagExitToTab] : nil;   
    }
	
	imageRect = CGRectMake(0, 0, 320, 416);
	imageRect.origin.x = [attributeDict objectForKey:kTagZoomX] ?
        [[attributeDict objectForKey:kTagZoomX] floatValue] : 
        imageRect.origin.x;
	imageRect.origin.y = [attributeDict objectForKey:kTagZoomX] ?
        [[attributeDict objectForKey:kTagZoomY] floatValue] :
        imageRect.origin.y;
	imageRect.size.width = [attributeDict objectForKey:kTagZoomX] ? [[attributeDict objectForKey:kTagZoomWidth] floatValue] : 
        imageRect.size.width;
	imageRect.size.height = [attributeDict objectForKey:kTagZoomX] ? [[attributeDict objectForKey:kTagZoomHeight] floatValue] :
        imageRect.size.height;

	resizeTime = [attributeDict objectForKey:kTagZoomTime] ? 
        [[attributeDict objectForKey:kTagZoomTime] floatValue] :
        kDefaultZoomTime;
	
	fgSoundMediaId = [attributeDict objectForKey:kTagFgSoundMediaId] ?
        [[attributeDict objectForKey: kTagFgSoundMediaId] intValue] :
        kEmptySound;
	bgSoundMediaId = [attributeDict objectForKey:kTagBgSoundMediaId] ?
        [[attributeDict objectForKey:kTagBgSoundMediaId] intValue] :
        kEmptySound;
    
	[self.currentText setString:@""];
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
    NSLog(@"SceneParser: Ended Element %@", elementName);
	
    if ([elementName isEqualToString:kTagPc] 
        || [elementName isEqualToString:kTagNpc])
	{
        Scene *newScene = [[Scene alloc] initWithText:currentText 
                                          isPc:isPc 
                                  imageMediaId:currentCharacterId
                                     imageRect:imageRect
                                      zoomTime:resizeTime
                              foreSoundMediaId:fgSoundMediaId
                              backSoundMediaId:bgSoundMediaId
                              exitToTabWithTitle:exitToTabWithTitle]; 

		[self.script addObject:newScene];
		[newScene release];
	}
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	// Not wrapped in CDATA, so hope for the best and add to it
	[self.currentText appendString:string];
	NSLog(@"SceneParser: WARNING: No CDATA used for %@", string);
}

- (void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	// Fond CDATA, so HTML should work.
	
	NSString *text = [[NSString alloc] initWithData:CDATABlock
										   encoding:NSUTF8StringEncoding];
	[self.currentText appendString:text];
	[text release];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"SceneParser: parserDidEndDocument");
	if ([script count] == 0) {
		// No parsing happened; use raw text
        Scene *s = [[Scene alloc] initWithText:sourceText 
                                          isPc:NO 
                                  imageMediaId:defaultImageMediaId
                                     imageRect:CGRectMake(0, 0, 320, 416)
                                      zoomTime:kDefaultZoomTime
                              foreSoundMediaId:kEmptySound
                              backSoundMediaId:kEmptySound
                              exitToTabWithTitle:nil];        
		
		[self.script addObject:s];
		[s release];
	}
	
	[self.sourceText release];
	self.sourceText = nil;
	
	NSLog(@"SceneParser: didFinishParsing");
	if (self.delegate) [self.delegate didFinishParsing];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"SceneParser: Fatal error: %@", parseError);
}
@end
