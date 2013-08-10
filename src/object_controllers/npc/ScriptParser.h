//
//  ScriptParser.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/12/01.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Script.h"
#import "ScriptElement.h"

@protocol ScriptParserDelegate
- (void) scriptDidFinishParsing:(Script *)s;
@end

@interface ScriptParser : NSObject <NSXMLParserDelegate>
{
    NSXMLParser		*parser;
    NSString		*sourceText;

    Script *script;
    
	id<ScriptParserDelegate> __unsafe_unretained delegate;
}

@property (nonatomic,strong) Script *script;

- (id) initWithDelegate:(id<ScriptParserDelegate>)inputDelegate;
- (void) parseText:(NSString *)text;

@end
