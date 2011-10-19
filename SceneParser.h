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
- (void) didFinishParsing;
@end


@interface SceneParser : NSObject <NSXMLParserDelegate> {
	Boolean			isPc;
	NSInteger		currentCharacterId;
	NSMutableString *currentText;
	NSInteger		defaultImageMediaId;
    int				fgSoundMediaId;
	int				bgSoundMediaId;
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
    NSXMLParser		*parser;
	id<SceneParserDelegate> delegate;
}

@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSMutableArray *script;
@property (nonatomic, retain) NSString *sourceText;
@property (nonatomic, retain) NSString *exitToTabWithTitle;
@property (nonatomic, retain) NSString *exitToType;

@property (readwrite, retain) id<SceneParserDelegate> delegate;



- (id) initWithDefaultNpcId:(NSInteger)anNpcId;

- (void) parseText:(NSString *)text;

@end
