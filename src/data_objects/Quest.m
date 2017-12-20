//
//  Quest.m
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Quest.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation Quest

@synthesize quest_id;
@synthesize name;
@synthesize desc;
@synthesize quest_type;

@synthesize active_icon_media_id;
@synthesize active_media_id;
@synthesize active_desc;
@synthesize active_notification_type;
@synthesize active_function;
@synthesize active_event_package_id;
@synthesize active_requirement_root_package_id;

@synthesize complete_icon_media_id;
@synthesize complete_media_id;
@synthesize complete_desc;
@synthesize complete_notification_type;
@synthesize complete_function;
@synthesize complete_event_package_id;
@synthesize complete_requirement_root_package_id;

@synthesize sort_index;
@synthesize parent_quest_id;

- (Quest *) init
{
    if(self = [super init])
    {
        quest_id = 0;
        name = @"";
        desc = @"";
        quest_type = @"QUEST";

        active_icon_media_id = 0;
        active_media_id = 0;
        active_desc = @"";
        active_notification_type = @"NONE";
        active_function = @"NONE";
        active_event_package_id = 0;
        active_requirement_root_package_id = 0;

        complete_icon_media_id = 0;
        complete_media_id = 0;
        complete_desc = @"";
        complete_notification_type = @"NONE";
        complete_function = @"NONE";
        complete_event_package_id = 0;
        complete_requirement_root_package_id = 0;

        sort_index = 0;
        parent_quest_id = 0;
    }
    return self;
}

- (Quest *) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    quest_id                             = [dict validIntForKey:@"quest_id"];
    name                                 = [dict validStringForKey:@"name"];
    desc                                 = [dict validStringForKey:@"description"];
    quest_type                           = [dict validStringForKey:@"quest_type"];

    active_icon_media_id                 = [dict validIntForKey:@"active_icon_media_id"];
    active_media_id                      = [dict validIntForKey:@"active_media_id"];
    active_desc                          = [dict validStringForKey:@"active_description"];
    active_notification_type             = [dict validStringForKey:@"active_notification_type"];
    active_function                      = [dict validStringForKey:@"active_function"];
    active_event_package_id              = [dict validIntForKey:@"active_event_package_id"];
    active_requirement_root_package_id   = [dict validIntForKey:@"active_requirement_root_package_id"];

    complete_icon_media_id               = [dict validIntForKey:@"complete_icon_media_id"];
    complete_media_id                    = [dict validIntForKey:@"complete_media_id"];
    complete_desc                        = [dict validStringForKey:@"complete_description"];
    complete_notification_type           = [dict validStringForKey:@"complete_notification_type"];
    complete_function                    = [dict validStringForKey:@"complete_function"];
    complete_event_package_id            = [dict validIntForKey:@"complete_event_package_id"];
    complete_requirement_root_package_id = [dict validIntForKey:@"complete_requirement_root_package_id"];

    sort_index                           = [dict validIntForKey:@"sort_index"];
    parent_quest_id                      = [dict validIntForKey:@"parent_quest_id"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",quest_id] forKey:@"quest_id"];
  [d setObject:name forKey:@"name"];
  [d setObject:desc forKey:@"description"];
  [d setObject:quest_type forKey:@"quest_type"];

  [d setObject:[NSString stringWithFormat:@"%ld",active_icon_media_id] forKey:@"active_icon_media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",active_media_id] forKey:@"active_media_id"];
  [d setObject:active_desc forKey:@"active_description"];
  [d setObject:active_notification_type forKey:@"active_notification_type"];
  [d setObject:active_function forKey:@"active_function"];
  [d setObject:[NSString stringWithFormat:@"%ld",active_event_package_id] forKey:@"active_event_package_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",active_requirement_root_package_id] forKey:@"active_requirement_root_package_id"];

  [d setObject:[NSString stringWithFormat:@"%ld",complete_icon_media_id] forKey:@"complete_icon_media_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",complete_media_id] forKey:@"complete_media_id"];
  [d setObject:complete_desc forKey:@"complete_description"];
  [d setObject:complete_notification_type forKey:@"complete_notification_type"];
  [d setObject:complete_function forKey:@"complete_function"];
  [d setObject:[NSString stringWithFormat:@"%ld",complete_event_package_id] forKey:@"complete_event_package_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",complete_requirement_root_package_id] forKey:@"complete_requirement_root_package_id"];

  [d setObject:[NSString stringWithFormat:@"%ld",sort_index] forKey:@"sort_index"];
  [d setObject:[NSString stringWithFormat:@"%ld",parent_quest_id] forKey:@"parent_quest_id"];
  return [NSString JSONFromFlatStringDict:d];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Quest- Id:%ld\tName:%@",self.quest_id,self.name];
}

@end

