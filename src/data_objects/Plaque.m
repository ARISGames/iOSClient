//
//  Plaque.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Plaque.h"
#import "PlaqueViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Plaque

@synthesize plaque_id;
@synthesize name;
@synthesize desc;
@synthesize icon_media_id;
@synthesize media_id;
@synthesize event_package_id;

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
    }
    return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.plaque_id        = [dict validIntForKey:@"plaque_id"];
        self.name             = [dict validObjectForKey:@"name"];
        self.desc             = [dict validObjectForKey:@"description"];
        self.media_id         = [dict validIntForKey:@"media_id"];
        self.icon_media_id    = [dict validIntForKey:@"icon_media_id"];
        self.event_package_id = [dict validIntForKey:@"event_package_id"];
    }
    return self;
}

- (Plaque *) copy
{
    Plaque *c = [[Plaque alloc] init];
    c.plaque_id        = self.plaque_id;
    c.name             = self.name;
    c.desc             = self.desc;
    c.media_id         = self.media_id;
    c.icon_media_id    = self.icon_media_id;
    c.event_package_id = self.event_package_id;
    
    return c;
}

- (int) compareTo:(Plaque *)ob
{
	return (ob.plaque_id == self.plaque_id);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Plaque- Id:%d\tName:%@\tDesc:%@\t",self.plaque_id,self.name,self.desc];
}

@end
