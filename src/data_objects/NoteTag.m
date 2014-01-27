//
//  NoteTag.m
//  ARIS
//
//  Created by Brian Thiel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteTag.h"
#import "NSDictionary+ValidParsers.h"

@implementation NoteTag

@synthesize noteTagId;
@synthesize text;
@synthesize playerCreated;

- (NoteTag *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.text          = [dict validStringForKey:@"tag"];
        self.playerCreated = [dict validBoolForKey:@"player_created"];
        self.noteTagId     = [dict validIntForKey:@"tag_id"];
    }
    return self;
}

@end
