//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "NSDictionary+ValidParsers.h"

@implementation Note

@synthesize note_id;
@synthesize user_id;
@synthesize name;
@synthesize desc;
@synthesize media_id;
@synthesize created;

- (id) init
{
    if (self = [super init])
    {
      self.note_id = 0;
      self.user_id = 0;
      self.name = @"";
      self.desc = @"";
      self.media_id = 0;
      self.created = [[NSDate alloc] init];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.note_id  = [dict validIntForKey:@"note_id"];
        self.user_id  = [dict validIntForKey:@"user_id"];
        self.name     = [dict validObjectForKey:@"name"];
        self.desc     = [dict validObjectForKey:@"description"];
        self.media_id = [dict validIntForKey:@"media_id"];
        self.created  = [dict validDateForKey:@"created"];
    }
    return self;
}

- (void) mergeDataFromNote:(Note *)n //allows for notes to be updated easily- all things with this note pointer now have access to latest note data
{
  self.note_id  = n.note_id;
  self.user_id  = n.user_id;
  self.name     = n.name;
  self.desc     = n.desc;
  self.media_id = n.media_id;
  self.created  = n.created;
}

- (long) icon_media_id
{
    return -6;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Note- Id:%ld\tName:%@\tOwner:%ld\t",self.note_id,self.name,self.user_id];
}

@end
