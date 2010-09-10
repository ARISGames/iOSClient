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


@interface SceneParser : NSObject {
	Boolean			isPc;
	NSInteger		currentCharacterId;
	NSMutableString	*currentText;
	NSInteger		defaultNpcId;
	
	NSXMLParser		*parser;
	
	NSMutableArray	*script;
	NSString		*sourceText;
	CGRect			zoomRect;
	float			zoomTime;
	
	int				fgSound;
	int				bgSound;
	
	id<SceneParserDelegate> delegate;
}
@property (readwrite, retain) id<SceneParserDelegate> delegate;
@property (readonly) NSArray *script;

- (id) initWithDefaultNpcId:(NSInteger)anNpcId;

- (void) parseText:(NSString *)text;

@end
