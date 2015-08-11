//
//  Plaque.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Plaque.h"
#import "Media.h"
#import "NSDictionary+ValidParsers.h"

@implementation Plaque

@synthesize plaque_id;
@synthesize name;
@synthesize desc;
@synthesize icon_media_id;
@synthesize media_id;
@synthesize event_package_id;
@synthesize back_button_enabled;

- (id) init
{
    if(self = [super init])
    {
        self.plaque_id = 0;
        self.name = @"Plaque";
        self.desc = @"Text";
        self.icon_media_id = 0;
        self.media_id = 0;
        self.event_package_id = 0;
        self.back_button_enabled = YES;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.plaque_id           = [dict validIntForKey:@"plaque_id"];
        self.name                = [dict validObjectForKey:@"name"];
        self.desc                = [dict validObjectForKey:@"description"];
        self.media_id            = [dict validIntForKey:@"media_id"];
        self.icon_media_id       = [dict validIntForKey:@"icon_media_id"];
        self.event_package_id    = [dict validIntForKey:@"event_package_id"];
        self.back_button_enabled = [dict validBoolForKey:@"back_button_enabled"];
    }
    return self;
}

- (long) icon_media_id
{
    if(!icon_media_id) return DEFAULT_PLAQUE_ICON_MEDIA_ID;
    return icon_media_id;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Plaque- Id:%ld\tName:%@\tDesc:%@\t",self.plaque_id,self.name,self.desc];
}

@end
