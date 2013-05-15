//
//  SceneParser.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogScript.h"
#import "Scene.h"

@protocol SceneParserDelegate
- (void) didFinishParsing:(DialogScript *)s;
@end

@interface SceneParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser		*parser;
    NSString		*sourceText;

    DialogScript *script;
    
	id<SceneParserDelegate> __unsafe_unretained delegate;
}

@property (nonatomic,strong) DialogScript *script;

- (id) initWithDelegate:(id<SceneParserDelegate>)inputDelegate;

- (void) parseText:(NSString *)text;

@end
