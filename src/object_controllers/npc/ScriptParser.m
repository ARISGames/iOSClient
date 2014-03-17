//
//  ScriptParser.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "ScriptParser.h"
#import "NSDictionary+ValidParsers.h"

/*
 SAMPLE DIALOG FORMAT
 NSString *xmlData =
 @"<dialog>"
 @"<pc bgSound='1'>Tell me more.</pc>"
 @"<pc zoomX='130' zoomY='35' zoomWidth='50' zoomHeight='71.875'><![CDATA[I'm really interested.]]></pc>"
 @"<npc fgSound='2' id='1'><![CDATA[<p>So a man walks into a bar.</p>]]></npc>"
 @"<npc id='2'><![CDATA[<p>This is the good part.</p>]]></npc>"
 @"<npc bgSound='-2' id='1'><![CDATA[<p><strong>Quiet!</strong></p><p>Anyway, he says ouch.</p>]]></npc>"
 @"<npc id='2' zoomX='150' zoomY='50' zoomWidth='100' zoomHeight='100'><![CDATA[<p><strong>OUCH!</strong></p><p>Ha ha ha!</p>]]></npc>"
 @"</dialog>";
 */

const float kDefaultZoomTime = 1.0;

NSString *const kTagDialog                       = @"dialog";
NSString *const kTagPc                           = @"pc";
NSString *const kTagNpc                          = @"npc";

NSString *const kTagVideo                        = @"video";
NSString *const kTagPanoramic                    = @"panoramic";
NSString *const kTagWebPage                      = @"webpage";
NSString *const kTagPlaque                       = @"plaque";
NSString *const kTagItem                         = @"item";
NSString *const kAttrId                          = @"id";

NSString *const kAttrTitle                       = @"title";
NSString *const kAttrMedia                       = @"mediaId";

NSString *const kAttrHideLeaveConversationButton = @"hideLeaveConversationButton";
NSString *const kAttrLeaveButtonTitle            = @"leaveButtonTitle";
NSString *const kAttrDefaultPcTitle              = @"pcTitle";
NSString *const kAttrDefaultPcMediaId            = @"pcMediaId";

NSString *const kAttrExitToTab                   = @"exitToTab";
NSString *const kAttrExitToScannerWithPrompt     = @"exitToScannerWithPrompt";
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

@interface ScriptParser () <NSXMLParserDelegate>
{
    NSXMLParser	*parser;
    NSString	*sourceText;
    
    ScriptElement *tempScriptElement;
    NSMutableString *tempText; 

    Script *script;
    
	id<ScriptParserDelegate> __unsafe_unretained delegate;
}
@end

@implementation ScriptParser

@synthesize script;

- (id) initWithDelegate:(id<ScriptParserDelegate>)inputDelegate
{
	if(self = [super init])
    {
        parser = nil;
        sourceText = nil;
		
        delegate = inputDelegate;
	}
	return self;
}

- (void) parseText:(NSString *)text
{
	sourceText = text;
    script = [[Script alloc] init];
    
    //This is a hack. NSXMLParser refuses to call any delegate methods with a string < 3 length.
    if(text.length <= 3)
    {
        ScriptElement *s = [[ScriptElement alloc] init];
        s.type = @"npc";
        s.text = sourceText;
        [script.scriptElementArray addObject:s]; 
        
       	[delegate scriptDidFinishParsing:script]; 
        return;
    }
	
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
	parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	
	[parser parse];
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:kTagDialog])
    {
        if([attributeDict objectForKey:kAttrExitToTab])
        {
            script.exitToType = @"tab";
            script.exitToTabTitle = [attributeDict validStringForKey:kAttrExitToTab];
        }
        else if([attributeDict objectForKey:kAttrExitToScannerWithPrompt])
        {
            script.exitToType = @"scanner";
            script.exitToTabTitle = [attributeDict validStringForKey:kAttrExitToScannerWithPrompt]; 
        } 
        else if([attributeDict objectForKey:kAttrExitToPlaque])
        {
            script.exitToType = @"plaque";
            script.exitToTypeId = [attributeDict validIntForKey:kAttrExitToPlaque];
        }
        else if([attributeDict objectForKey:kAttrExitToWebPage])
        {
            script.exitToType = @"webpage";
            script.exitToTypeId = [attributeDict validIntForKey:kAttrExitToWebPage];
        }
        else if([attributeDict objectForKey:kAttrExitToItem])
        {
            script.exitToType = @"item";
            script.exitToTypeId = [attributeDict validIntForKey:kAttrExitToItem];
        }
        else if([attributeDict objectForKey:kAttrExitToCharacter])
        {
            script.exitToType = @"character";
            script.exitToTypeId = [attributeDict validIntForKey:kAttrExitToCharacter];
        }
        else if([attributeDict objectForKey:kAttrExitToPanoramic])
        {
            script.exitToType = @"panoramic";
            script.exitToTypeId = [attributeDict validIntForKey:kAttrExitToPanoramic];
        }
        
        //These two are weird, and should in stead be a member of the parent class that contains all conversations (the npc?)
        //because it takes effect in between scripts
        if([attributeDict objectForKey:kAttrHideLeaveConversationButton])
        {
            script.hideLeaveConversationButtonSpecified = YES; //This is dumb, but setting it to "NO" and doing nothing need to be regarded differently
            script.hideLeaveConversationButton = [attributeDict validBoolForKey:kAttrHideLeaveConversationButton];
        }
        if([attributeDict objectForKey:kAttrLeaveButtonTitle])
            script.leaveConversationButtonTitle = [attributeDict validStringForKey:kAttrLeaveButtonTitle];
        if([attributeDict objectForKey:kAttrDefaultPcTitle])
            script.defaultPcTitle = [attributeDict validStringForKey:kAttrDefaultPcTitle];
       if([attributeDict objectForKey:kAttrDefaultPcMediaId])
           script.defaultPcMediaId = [attributeDict validIntForKey:kAttrDefaultPcMediaId]; 
        // end weirdness
    }
    else
    {
        tempScriptElement = [[ScriptElement alloc] init];
        tempText = [[NSMutableString alloc] init];

        if([elementName isEqualToString:kTagNpc] || [elementName isEqualToString:kTagPc])
        {
            if([elementName isEqualToString:kTagNpc]) tempScriptElement.type = @"npc";
            if([elementName isEqualToString:kTagPc])  tempScriptElement.type = @"pc";
        
            if([attributeDict objectForKey:kAttrTitle])        tempScriptElement.title        = [attributeDict objectForKey:kAttrTitle];
            if([attributeDict objectForKey:kAttrMedia])        tempScriptElement.mediaId      = [[attributeDict objectForKey:kAttrMedia] intValue];
            if([attributeDict objectForKey:kAttrVibrate])      tempScriptElement.vibrate      = YES;
            if([attributeDict objectForKey:kAttrNotification]) tempScriptElement.notification = [attributeDict objectForKey:kAttrNotification];
            
            int x = 0;
            int y = 0;
            int width  = 320;
            int height = [UIScreen mainScreen].applicationFrame.size.height-44;
            if([attributeDict objectForKey:kAttrZoomX])      x      = [[attributeDict objectForKey:kAttrZoomX] intValue];
            if([attributeDict objectForKey:kAttrZoomY])      y      = [[attributeDict objectForKey:kAttrZoomY] intValue];
            if([attributeDict objectForKey:kAttrZoomWidth])  width  = [[attributeDict objectForKey:kAttrZoomWidth] intValue];
            if([attributeDict objectForKey:kAttrZoomHeight]) height = [[attributeDict objectForKey:kAttrZoomHeight] intValue];
            tempScriptElement.imageRect = CGRectMake(x,y,width,height);

            if([attributeDict objectForKey:kAttrZoomTime])
                tempScriptElement.zoomTime = [[attributeDict objectForKey:kAttrZoomTime] floatValue];
        }
        else if([elementName isEqualToString:kTagVideo]     ||
                [elementName isEqualToString:kTagPanoramic] ||
                [elementName isEqualToString:kTagWebPage]   ||
                [elementName isEqualToString:kTagPlaque]    ||
                [elementName isEqualToString:kTagItem]       )
        {
            if([elementName isEqualToString:kTagItem])      tempScriptElement.type = @"item";
            if([elementName isEqualToString:kTagPlaque])    tempScriptElement.type = @"node";
            if([elementName isEqualToString:kTagWebPage])   tempScriptElement.type = @"webpage";
            if([elementName isEqualToString:kTagPanoramic]) tempScriptElement.type = @"panoramic";
            if([elementName isEqualToString:kTagVideo])     tempScriptElement.type = @"video";
            
            tempScriptElement.typeId = [[attributeDict objectForKey:kAttrId] intValue];
        }
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if(tempScriptElement && ![elementName isEqualToString:kTagDialog])
    {
        tempScriptElement.text = [NSString stringWithString:tempText];
        [script.scriptElementArray addObject:tempScriptElement];
        tempScriptElement = nil;
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
	NSLog(@"ScriptParser: parserDidEndDocument");
	if([script.scriptElementArray count] == 0)
    {
        ScriptElement *s = [[ScriptElement alloc] init];
        s.type = @"npc";
        s.text = sourceText;
        [script.scriptElementArray addObject:s];
	}
	
	[delegate scriptDidFinishParsing:script];
}

- (void) parser:(NSXMLParser *)p parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"ScriptParser: Fatal error: %@", parseError);
}
@end
