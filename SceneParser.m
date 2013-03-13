//
//  SceneParser.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "SceneParser.h"

const float kDefaultZoomTime = 1.0;

NSString *const kTagPc                          = @"pc";
NSString *const kTagNpc                         = @"npc";
NSString *const kTagDialog                      = @"dialog";
NSString *const kTagPcTitle                     = @"pcTitle";
NSString *const kTagPcMediaId                   = @"pcMediaId";
NSString *const kTagLeaveButtonTitle            = @"leaveButtonTitle";
NSString *const kTagHideLeaveConversationButton = @"hideLeaveConversationButton";
NSString *const kTagHideAdjustTextAreaButton    = @"hideAdjustTextAreaButton";
NSString *const kTagAdjustTextArea              = @"adjustTextArea";
NSString *const kTagExitToTab                   = @"exitToTab";
NSString *const kTagExitToPlaque                = @"exitToPlaque";
NSString *const kTagExitToWebPage               = @"exitToWebPage";
NSString *const kTagExitToCharacter             = @"exitToCharacter";
NSString *const kTagExitToPanoramic             = @"exitToPanoramic";
NSString *const kTagExitToItem                  = @"exitToItem";
NSString *const kTagZoomX                       = @"zoomX";
NSString *const kTagZoomY                       = @"zoomY";
NSString *const kTagZoomWidth                   = @"zoomWidth";
NSString *const kTagZoomHeight                  = @"zoomHeight";
NSString *const kTagZoomTime                    = @"zoomTime";
NSString *const kTagVideo                       = @"video";
NSString *const kTagId                          = @"id";
NSString *const kTagPanoramic                   = @"panoramic";
NSString *const kTagWebpage                     = @"webpage";
NSString *const kTagPlaque                      = @"plaque";
NSString *const kTagItem                        = @"item";
NSString *const kTagMedia                       = @"mediaId";
NSString *const kTagTitle                       = @"title";
NSString *const kTagVibrate                     = @"vibrate";
NSString *const kTagNotification                = @"notification";

@implementation SceneParser
@synthesize currentText, sourceText, exitToTabWithTitle, delegate, script, exitToType, title, isPc, vibrate, notification;

#pragma mark Init/dealloc
- (id) initWithDefaultNpcIdWithDelegate:(id)inputDelegate
{
	if ((self = [super init]))
    {
        parser = nil;
        self.sourceText = nil;
		self.currentText = [[NSMutableString alloc] init];
		self.script = [[NSMutableArray alloc] init];
		self.delegate = inputDelegate;
	}
	return self;
}


#pragma mark XML Parsing
- (void) parseText:(NSString *)text
{
	self.sourceText = text;
	[script removeAllObjects];
	
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	
	[parser parse];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	NSLog(@"SceneParser: Starting Element %@", elementName);
    vibrate = NO;
    if ([attributeDict objectForKey:kTagHideLeaveConversationButton]) {
        [self.delegate setHideLeaveConversationButton: ([attributeDict objectForKey:kTagHideLeaveConversationButton] ? [[attributeDict objectForKey:kTagHideLeaveConversationButton]intValue] : 0)];
    }
    
    if ([attributeDict objectForKey:kTagHideAdjustTextAreaButton]) {
        [self.delegate hideAdjustTextAreaButton: ([attributeDict objectForKey:kTagHideAdjustTextAreaButton] ? [[attributeDict objectForKey:kTagHideAdjustTextAreaButton]intValue] : 0)];
    }
    
    if ([attributeDict objectForKey:kTagAdjustTextArea]){
        [self.delegate adjustTextArea: [attributeDict objectForKey:kTagAdjustTextArea]];
    }
    
    if ([attributeDict objectForKey:kTagTitle]) {
        title = [attributeDict objectForKey:kTagTitle] ? [attributeDict objectForKey:kTagTitle] : @"";
    }
    else title = nil;
    
    if ([attributeDict objectForKey:kTagPcTitle]) {
        [self.delegate setPcTitle:[attributeDict objectForKey:kTagPcTitle]];
    }
    
    if ([attributeDict objectForKey:kTagPcMediaId] && [[attributeDict objectForKey:kTagPcMediaId] intValue] != 0) {
        [self.delegate setPcMediaId:[[attributeDict objectForKey:kTagPcMediaId] intValue]];
    }
    
    if ([attributeDict objectForKey:kTagLeaveButtonTitle]) {
        [self.delegate setLeaveButtonTitle:[attributeDict objectForKey:kTagLeaveButtonTitle]];
    }
    
    if ([attributeDict objectForKey:kTagVibrate]) {
        if([[attributeDict objectForKey:kTagVibrate]intValue] > 0) vibrate = YES;
    }
    
    if ([attributeDict objectForKey:kTagNotification]) {
        notification = [attributeDict objectForKey:kTagNotification];
    } 
    
    if ([elementName isEqualToString:kTagPc]) {
		isPc = YES;
    }
    
	else if ([elementName isEqualToString:kTagNpc]){ 
        isPc = NO;
        if ([attributeDict objectForKey:kTagMedia]) {
            mediaId = [attributeDict objectForKey:kTagMedia] ? [[attributeDict objectForKey:kTagMedia]intValue] : 0;
        }
    }    
    else if ([elementName isEqualToString:kTagDialog]) {
        
        if ([attributeDict objectForKey:kTagExitToTab]){
            exitToType = @"tab";
            exitToTabWithTitle = [attributeDict objectForKey:kTagExitToTab];
        }
        else if([attributeDict objectForKey:kTagExitToPlaque]){
            exitToType = @"plaque";
            exitToTabWithTitle = [attributeDict objectForKey:kTagExitToPlaque];
        }
        else if([attributeDict objectForKey:kTagExitToWebPage]){
            exitToType = @"webpage";
            exitToTabWithTitle = [attributeDict objectForKey:kTagExitToWebPage];
        }
        else if([attributeDict objectForKey:kTagExitToItem]){
            exitToType = @"item";
            exitToTabWithTitle = [attributeDict objectForKey:kTagExitToItem];
        }
        else if([attributeDict objectForKey:kTagExitToCharacter]){
            exitToType = @"character";
            exitToTabWithTitle = [attributeDict objectForKey:kTagExitToCharacter];
        }
        else if([attributeDict objectForKey:kTagExitToPanoramic]){
            exitToType = @"panoramic";
            exitToTabWithTitle = [attributeDict objectForKey:kTagExitToPanoramic];
        }
        else {
            exitToType = nil;
            exitToTabWithTitle = nil;
        }
    }
    else if ([elementName isEqualToString:kTagVideo]){
        videoId = [attributeDict objectForKey:kTagId] ? [[attributeDict objectForKey:kTagId]intValue] : 0;
    }
    
    else if ([elementName isEqualToString:kTagPanoramic]) {
        panoId = [attributeDict objectForKey:kTagId] ? [[attributeDict objectForKey:kTagId]intValue] : 0;
    }
    else if ([elementName isEqualToString:kTagWebpage]) {
        webId = [attributeDict objectForKey:kTagId] ? [[attributeDict objectForKey:kTagId]intValue] : 0;
    }
    else if ([elementName isEqualToString:kTagPlaque]) {
        plaqueId = [attributeDict objectForKey:kTagId] ? [[attributeDict objectForKey:kTagId]intValue] : 0;
    }
    else if ([elementName isEqualToString:kTagItem]) {
        itemId = [attributeDict objectForKey:kTagId] ? [[attributeDict objectForKey:kTagId]intValue] : 0;
    }
    
	imageRect = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height-NOTIFICATIONBARHEIGHT);
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
    
	[self.currentText setString:@""];
    NSLog(@"Scene Parser: Is Pc: %d", isPc);
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
    NSLog(@"SceneParser: Ended Element %@", elementName);
	
    if ([elementName isEqualToString:kTagPc] 
        || [elementName isEqualToString:kTagNpc] 
        || [elementName isEqualToString:kTagPanoramic] 
        || [elementName isEqualToString:kTagVideo]
        || [elementName isEqualToString:kTagWebpage]
        || [elementName isEqualToString:kTagPlaque]
        || [elementName isEqualToString:kTagItem])
	{
        Scene *newScene = [[Scene alloc] initWithText:currentText
                                                 isPc:isPc
                                        shouldVibrate:vibrate
                                            imageRect:imageRect
                                             zoomTime:resizeTime
                                   exitToTabWithTitle:exitToTabWithTitle
                                           exitToType:exitToType
                                              videoId:videoId
                                          panoramicId:panoId
                                            webpageId:webId
                                             plaqueId:plaqueId
                                               itemId:itemId
                                              mediaId:mediaId
                                                title:title];
        NSLog(@"MediaId in Scene is: %d", mediaId);
        NSLog(@"Scene Parser: Is Pc: %d", isPc);
        newScene.notification = notification;
		[self.script addObject:newScene];
        panoId = 0;
        videoId = 0;
        webId = 0;
        mediaId = 0;
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
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"SceneParser: parserDidEndDocument");
	if ([script count] == 0) {
		// No parsing happened; use raw text
        Scene *s = [[Scene alloc] initWithText:sourceText 
                                          isPc:NO
                                 shouldVibrate:NO
                                     imageRect:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height-NOTIFICATIONBARHEIGHT)
                                      zoomTime:kDefaultZoomTime
                              exitToTabWithTitle:nil exitToType:nil
                                       videoId:0 panoramicId:0 webpageId:0 plaqueId:0 itemId:0 mediaId:0 title:@""];
		[self.script addObject:s];
	}
	
	NSLog(@"SceneParser: didFinishParsing");
	if (self.delegate) [self.delegate didFinishParsing];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"SceneParser: Fatal error: %@", parseError);
}
@end
