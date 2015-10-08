//
//  NoteComment.m
//  ARIS
//
//  Created by Phil Dougherty on 1/23/14.
//
//

#import "NoteComment.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"
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
    self.name            = [dict validStringForKey:@"name"];
    self.desc            = [dict validStringForKey:@"description"];
    self.created         = [dict validDateForKey:@"created"];

    if([dict validObjectForKey:@"user"] != nil && [[dict validObjectForKey:@"user"] validStringForKey:@"display_name"] != nil)
    {
      self.user_display_name = [[dict validObjectForKey:@"user"] validStringForKey:@"display_name"];
    }
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.note_comment_id] forKey:@"note_comment_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.note_id] forKey:@"note_id"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.user_id] forKey:@"user_id"];
  [d setObject:self.name forKey:@"name"];
  [d setObject:self.desc forKey:@"desc"];
  [d setObject:[self.created descriptionWithLocale:nil] forKey:@"created"];
  return [NSString JSONFromFlatStringDict:d];
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

