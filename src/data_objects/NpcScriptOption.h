//
//  NpcScriptOption.h
//  ARIS
//
//  Created by Kevin Harris on 5/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NpcScriptOption : NSObject
{
	NSString *optionText;
    NSString *scriptText;
	NSInteger nodeId;
    BOOL hasViewed;
}

@property(readwrite, strong) NSString *optionText;
@property(readwrite, strong) NSString *scriptText;
@property(readwrite, assign) NSInteger nodeId;
@property(readwrite, assign) BOOL hasViewed;

- (id) initWithOptionText:(NSString *)t scriptText:(NSString *)s nodeId:(int)n hasViewed:(BOOL)v;

@end