//
//  SceneParser.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "SceneParser.h"

const float kDefaultZoomTime = 1.0;

NSString *const kTagDialog                      = @"dialog";
NSString *const kTagPc                          = @"pc";
NSString *const kTagNpc                         = @"npc";

NSString *const kTagVideo                       = @"video";
NSString *const kTagPanoramic                   = @"panoramic";
NSString *const kTagWebPage                     = @"webpage";
NSString *const kTagPlaque                      = @"plaque";
NSString *const kTagItem                        = @"item";
NSString *const kAttrId                          = @"id";

NSString *const kAttrTitle                       = @"title";
NSString *const kAttrMedia                       = @"mediaId";

NSString *const kAttrHideLeaveConversationButton = @"hideLeaveConversationButton";
NSString *const kAttrLeaveButtonTitle            = @"leaveButtonTitle";

NSString *const kAttrHideAdjustTextAreaButton    = @"hideAdjustTextAreaButton";
NSString *const kAttrAdjustTextArea              = @"adjustTextArea";

NSString *const kAttrExitToTab                   = @"exitToTab";
NSString *const kAttrExitToPlaque                = @"exitToPlaque";
NSString *const kAttrExitToWebPage               = @"exitToWebPage";
NSString *const kAttrExitToCharacter             = @"exitToCharacter";
NSString *const kAttrExitToPanoramic             = @"exitToPanoramic";
NSString *const kAttrExitToItem                  = @"exitToItem";

NSString *const kAttrZoomX                       = @"zoomX";
NSString *const kAttrZoomY                       = @"zoomY";
NSString *const kAttrZoomWidth                   = @"zoomWidth";
NSString *const kAttrZoomHeight                  = @"zoomHeight";
NSString *const kAttrZoomTime                    = @"zoomTime";

NSString *const kAttrVibrate                     = @"vibrate";
NSString *const kAttrNotification                = @"notification";

@implementation SceneParser
{
    Scene *tempScene;
    NSMutableString *tempText;
}

@synthesize script;

#pragma mark Init/dealloc
- (id) initWithDelegate:(id<SceneParserDelegate>)inputDelegate
{
	if ((self = [super init]))
    {
        parser = nil;
        sourceText = nil;
		
        delegate = inputDelegate;
	}
	return self;
}

#pragma mark XML Parsing
- (void) parseText:(NSString *)text
{
	sourceText = text;
	
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	
    script = [[DialogScript alloc] init];
    
	[parser parse];
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:kTagDialog])
    {
        if ([attributeDict objectForKey:kAttrExitToTab])
        {
            script.exitToType = @"tab";
            script.exitToTabTitle = [attributeDict objectForKey:kAttrExitToTab];
        }
        else if([attributeDict objectForKey:kAttrExitToPlaque])
        {
            script.exitToType = @"plaque";
            script.exitToTypeId = [[attributeDict objectForKey:kAttrExitToPlaque] intValue];
        }
        else if([attributeDict objectForKey:kAttrExitToWebPage])
        {
            script.exitToType = @"webpage";
            script.exitToTypeId = [[attributeDict objectForKey:kAttrExitToWebPage] intValue];
        }
        else if([attributeDict objectForKey:kAttrExitToItem])
        {
            script.exitToType = @"item";
            script.exitToTypeId = [[attributeDict objectForKey:kAttrExitToItem] intValue];
        }
        else if([attributeDict objectForKey:kAttrExitToCharacter])
        {
            script.exitToType = @"character";
            script.exitToTypeId = [[attributeDict objectForKey:kAttrExitToCharacter] intValue];
        }
        else if([attributeDict objectForKey:kAttrExitToPanoramic])
        {
            script.exitToType = @"panoramic";
            script.exitToTypeId = [[attributeDict objectForKey:kAttrExitToPanoramic] intValue];
        }
        
        //These two are weird, and should in stead be a member of the parent class that contains all conversations (the npc?)
        //because it takes effect in between scripts
        if([attributeDict objectForKey:kAttrHideLeaveConversationButton])
        {
            script.hideLeaveConversationButtonSpecified = YES; //This is dumb, but setting it to "NO" and doing nothing need to be regarded differently
            script.hideLeaveConversationButton = [[attributeDict objectForKey:kAttrHideLeaveConversationButton] boolValue];
        }
        if ([attributeDict objectForKey:kAttrLeaveButtonTitle])
            script.leaveConversationButtonTitle = [attributeDict objectForKey:kAttrLeaveButtonTitle];
        // end weirdness
            
        if([attributeDict objectForKey:kAttrHideAdjustTextAreaButton])
            script.hideAdjustTextAreaButton = [[attributeDict objectForKey:kAttrHideAdjustTextAreaButton] boolValue];
        if ([attributeDict objectForKey:kAttrAdjustTextArea])
            script.adjustTextArea = [attributeDict objectForKey:kAttrAdjustTextArea];
    }
    else
    {
        tempScene = [[Scene alloc] init];
        tempText  = [[NSMutableString alloc] init];

        if([elementName isEqualToString:kTagNpc] || [elementName isEqualToString:kTagPc])
        {
            if([elementName isEqualToString:kTagNpc]) tempScene.sceneType = @"npc";
            if([elementName isEqualToString:kTagPc])  tempScene.sceneType = @"pc";
        
            if([attributeDict objectForKey:kAttrAdjustTextArea])
                tempScene.adjustTextArea = [attributeDict objectForKey:kAttrAdjustTextArea];
            if([attributeDict objectForKey:kAttrTitle])
                tempScene.title = [attributeDict objectForKey:kAttrTitle];
            if([attributeDict objectForKey:kAttrMedia])
                tempScene.mediaId = [[attributeDict objectForKey:kAttrMedia] intValue];
            if([attributeDict objectForKey:kAttrVibrate])
                tempScene.vibrate = YES;
            if ([attributeDict objectForKey:kAttrNotification])
                tempScene.notification = [attributeDict objectForKey:kAttrNotification];
            
            int x = 0;
            int y = 0;
            int width  = 320;
            int height = [UIScreen mainScreen].applicationFrame.size.height-44;
            if([attributeDict objectForKey:kAttrZoomX])
                x = [[attributeDict objectForKey:kAttrZoomX] intValue];
            if([attributeDict objectForKey:kAttrZoomY])
                y = [[attributeDict objectForKey:kAttrZoomY] intValue];
            if([attributeDict objectForKey:kAttrZoomWidth])
                width = [[attributeDict objectForKey:kAttrZoomWidth] intValue];
            if([attributeDict objectForKey:kAttrZoomHeight])
                height = [[attributeDict objectForKey:kAttrZoomHeight] intValue];
            tempScene.imageRect = CGRectMake(x,y,width,height);

            if([attributeDict objectForKey:kAttrZoomTime])
                tempScene.zoomTime = [[attributeDict objectForKey:kAttrZoomTime] floatValue];            
        }
        else if ([elementName isEqualToString:kTagVideo]     ||
                 [elementName isEqualToString:kTagPanoramic] ||
                 [elementName isEqualToString:kTagWebPage]   ||
                 [elementName isEqualToString:kTagPlaque]    ||
                 [elementName isEqualToString:kTagItem]       )
        {
            if([elementName isEqualToString:kTagItem])      tempScene.sceneType = @"item";
            if([elementName isEqualToString:kTagPlaque])    tempScene.sceneType = @"node";
            if([elementName isEqualToString:kTagWebPage])   tempScene.sceneType = @"webpage";
            if([elementName isEqualToString:kTagPanoramic]) tempScene.sceneType = @"panoramic";
            if([elementName isEqualToString:kTagVideo])     tempScene.sceneType = @"video";
            
            tempScene.typeId = [[attributeDict objectForKey:kAttrId] intValue];
        }
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(tempScene && ![elementName isEqualToString:kTagDialog])
    {
        tempScene.text = [NSString stringWithString:tempText];
        [script.sceneArray addObject:tempScene];
        tempScene = nil;
        tempText  = nil;
    }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	// Not wrapped in CDATA, so hope for the best and add to it
	[tempText appendString:string];
}

- (void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	// Found CDATA, so HTML should work.
	NSString *text = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	[tempText appendString:text];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
	NSLog(@"SceneParser: parserDidEndDocument");
	if ([script.sceneArray count] == 0)
    {
        Scene *s = [[Scene alloc] init];
        s.sceneType = @"npc";
        s.text = sourceText;
        [script.sceneArray addObject:s];
	}
	
	[delegate didFinishParsing:script];
}

- (void) parser:(NSXMLParser *)p parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"SceneParser: Fatal error: %@", parseError);
}
@end
