//
//  NoteTag.h
//  ARIS
//
//  Created by Brian Thiel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteTag : NSObject
{
    int noteTagId; 
    NSString *text;
    BOOL playerCreated;
}

@property (nonatomic, assign) int noteTagId;
@property (nonatomic, strong) NSString *text;
@property (readwrite, assign) BOOL playerCreated;

- (NoteTag *) initWithDictionary:(NSDictionary *)dict;

@end
