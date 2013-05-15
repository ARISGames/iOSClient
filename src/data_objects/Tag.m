//
//  Tag.m
//  ARIS
//
//  Created by Brian Thiel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"
#import "NSDictionary+ValidParsers.h"

@implementation Tag

@synthesize tagName;
@synthesize playerCreated;
@synthesize tagId;

- (Tag *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.tagName       = [dict validStringForKey:@"tag"];
        self.playerCreated = [dict validBoolForKey:@"player_created"];
        self.tagId         = [dict validIntForKey:@"tag_id"];
    }
    return self;
}

@end
