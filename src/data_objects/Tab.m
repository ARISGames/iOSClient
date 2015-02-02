//
//  Tab.m
//  ARIS
//
//  Created by Brian Thiel on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tab.h"
#import "NSDictionary+ValidParsers.h"

@implementation Tab

@synthesize tab_id;
@synthesize type;
@synthesize name; 
@synthesize icon_media_id; 
@synthesize content_id;
@synthesize info; 
@synthesize sort_index;

- (id) init
{
    if(self = [super init])
    {
        self.tab_id = 0;
        self.type = @"MAP"; 
        self.name = self.type; 
        self.icon_media_id = 0; 
        self.content_id = 0;  
        self.info = @""; 
        self.sort_index = 0;   
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.tab_id        = [dict validIntForKey:@"tab_id"];
        self.type          = [dict validStringForKey:@"type"]; 
        self.name          = [dict validStringForKey:@"name"]; 
        self.icon_media_id = [dict validIntForKey:@"icon_media_id"]; 
        self.content_id    = [dict validIntForKey:@"content_id"];  
        self.info          = [dict validStringForKey:@"info"]; 
        self.sort_index    = [dict validIntForKey:@"sort_index"];    
    }
    return self;
}

- (NSString *) keyString
{
    return [NSString stringWithFormat:@"%ld%@%@%ld",self.tab_id,self.type,self.name,self.content_id];
}

@end