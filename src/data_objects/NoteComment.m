//
//  NoteComment.m
//  ARIS
//
//  Created by Phil Dougherty on 1/23/14.
//
//

#import "NoteComment.h"
#import "NSDictionary+ValidParsers.h"
#import "User.h"

@implementation NoteComment

@synthesize note_comment_id;
@synthesize note_id;
@synthesize user_id;
@synthesize name;
@synthesize desc;
@synthesize user_display_name;
@synthesize created;

- (id) init
{
    if (self = [super init])
    {
      self.note_comment_id = 0;
      self.note_id = 0;
      self.user_id = 0;
      self.name = @"";
      self.desc = @"";
      self.user_display_name = @"";
      self.created = [[NSDate alloc] init];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.note_comment_id = [dict validIntForKey:@"note_comment_id"];
        self.note_id         = [dict validIntForKey:@"note_id"];
        self.user_id         = [dict validIntForKey:@"user_id"];
        self.name            = [dict validObjectForKey:@"name"];
        self.desc            = [dict validObjectForKey:@"description"];
        self.created         = [dict validDateForKey:@"created"];

        if([dict validObjectForKey:@"user"] != nil && [[dict validObjectForKey:@"user"] validObjectForKey:@"display_name"] != nil)
        {
          self.user_display_name = [[dict validObjectForKey:@"user"] validObjectForKey:@"display_name"];
        }
    }
    return self;
}

- (void) mergeDataFromNoteComment:(NoteComment *)n
{
  self.note_comment_id   = n.note_comment_id;
  self.note_id           = n.note_id;
  self.user_id           = n.user_id;
  self.name              = n.name;
  self.desc              = n.desc;
  self.user_display_name = n.user_display_name;
  self.created           = n.created;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"NoteComment- Id:%ld\tName:%@\tOwner:%ld\t",self.note_comment_id,self.name,self.user_id];
}

@end
