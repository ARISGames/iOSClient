//
//  SceneParser.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@protocol SceneParserDelegate
- (void) setHideLeaveConversationButton:(BOOL) hide;
- (BOOL) hideLeaveConversationButton;
- (void) didFinishParsing;
@end


@interface SceneParser : NSObject <NSXMLParserDelegate> {
	Boolean			isPc;
	NSInteger		currentCharacterId;
	NSMutableString *currentText;
	NSMutableArray	*script;
	NSString		*sourceText;
	CGRect			imageRect;
	float			resizeTime;
    NSString        *exitToTabWithTitle;
    NSString        *exitToType;
    int             videoId;
    int             panoId;
    int             webId;
    int             plaqueId;
    int             itemId;
    int             mediaId;
    NSString        *title;
    NSXMLParser		*parser;
	id<SceneParserDelegate> delegate;
}

@property (nonatomic) NSMutableString *currentText;
@property (nonatomic) NSMutableArray *script;
@property (nonatomic) NSString *sourceText;
@property (nonatomic) NSString *exitToTabWithTitle;
@property (nonatomic) NSString *exitToType;
@property(nonatomic) NSString *title;

@property (readwrite) id<SceneParserDelegate> delegate;



- (id) initWithDefaultNpcIdWithDelegate:(id)inputDelegate;

- (void) parseText:(NSString *)text;

@end
