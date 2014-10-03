//
//  Quest.m
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Quest.h"
#import "NSDictionary+ValidParsers.h"

@implementation Quest

@synthesize quest_id;
@synthesize name;
@synthesize desc; 
    
@synthesize active_icon_media_id;
@synthesize active_media_id; 
@synthesize active_desc;
@synthesize active_notification_type; 
@synthesize active_function;  
@synthesize active_event_package_id;  
    
@synthesize complete_icon_media_id;
@synthesize complete_media_id; 
@synthesize complete_desc;
@synthesize complete_notification_type; 
@synthesize complete_function;   
@synthesize complete_event_package_id;   
    
@synthesize sort_index;

- (Quest *) init
{
    if(self = [super init])
    {
        quest_id = 0;
        name = @"";
        desc = @""; 
    
        active_icon_media_id = 0;
        active_media_id = 0; 
        active_desc = @"";
        active_notification_type = @"NONE"; 
        active_function = @"NONE";  
        active_event_package_id = 0;  
    
        complete_icon_media_id = 0;
        complete_media_id = 0; 
        complete_desc = @"";
        complete_notification_type = @"NONE"; 
        complete_function = @"NONE";   
        complete_event_package_id = 0;   
    
        sort_index = 0;
    }
    return self;	
}

- (Quest *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        quest_id                   = [dict validIntForKey:@"quest_id"];
        name                       = [dict validStringForKey:@"name"];
        desc                       = [dict validStringForKey:@"description"]; 
    
        active_icon_media_id       = [dict validIntForKey:@"active_icon_media_id"];
        active_media_id            = [dict validIntForKey:@"active_media_id"]; 
        active_desc                = [dict validStringForKey:@"active_description"];
        active_notification_type   = [dict validStringForKey:@"active_notification_type"]; 
        active_function            = [dict validStringForKey:@"active_function"];  
        active_event_package_id    = [dict validIntForKey:@"active_event_package_id"];  
    
        complete_icon_media_id     = [dict validIntForKey:@"complete_icon_media_id"];
        complete_media_id          = [dict validIntForKey:@"complete_media_id"]; 
        complete_desc              = [dict validStringForKey:@"complete_description"];
        complete_notification_type = [dict validStringForKey:@"complete_notification_type"]; 
        complete_function          = [dict validStringForKey:@"complete_function"];   
        complete_event_package_id  = [dict validIntForKey:@"complete_event_package_id"];   
    
        sort_index                 = [dict validIntForKey:@"sort_index"];
    }
    return self;	
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Quest- Id:%d\tName:%@",self.quest_id,self.name];
}

@end
