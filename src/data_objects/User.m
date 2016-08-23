//
//  User.m
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "User.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"
#import "AppServices.h"
#import "AppModel.h"

@implementation User

@synthesize user_id;
@synthesize user_name;
@synthesize display_name;
@synthesize group_name;
@synthesize email;
@synthesize media_id;
@synthesize read_write_key;
@synthesize location;

- (id) init
{
    if(self = [super init])
    {
        self.user_id        = 0;
        self.user_name      = @"Unknown Player";
        self.display_name   = @"Unknown Player";
        self.group_name     = @"";
        self.email          = @"";
        self.media_id       = 0;
        self.read_write_key = @"";
        self.location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.user_id        = [dict validIntForKey:@"user_id"];
    self.user_name      = [dict validStringForKey:@"user_name"];
    self.display_name   = [dict validStringForKey:@"display_name"];
    self.group_name     = [dict validStringForKey:@"group_name"];
    self.email          = [dict validStringForKey:@"email"];
    self.media_id       = [dict validIntForKey:@"media_id"];
    self.read_write_key = [dict validStringForKey:@"read_write_key"];
    self.location       = [dict validLocationForLatKey:@"latitude" lonKey:@"longitude"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.user_id] forKey:@"user_id"];
  [d setObject:self.user_name forKey:@"user_name"];
  [d setObject:self.display_name forKey:@"display_name"];
  [d setObject:self.group_name forKey:@"group_name"];
  [d setObject:self.email forKey:@"email"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.media_id] forKey:@"media_id"];
  [d setObject:self.read_write_key forKey:@"read_write_key"];
  [d setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude] forKey:@"latitude"];
  [d setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude] forKey:@"longitude"];
  return [NSString JSONFromFlatStringDict:d];
}

- (User *) mergeDataFromUser:(User *)u
{
  self.user_id        = u.user_id;
  self.user_name      = u.user_name;
  self.display_name   = u.display_name;
  self.group_name     = u.group_name;
  self.email          = u.email;
  self.media_id       = u.media_id;
  if(u.read_write_key && [u.read_write_key isEqualToString:@""])
      self.read_write_key = u.read_write_key; //only merge in read_write key if exists

  //load the player media immediately if possible
  if(u.media_id != 0) [_SERVICES_MEDIA_ loadMedia:[_MODEL_MEDIA_ mediaForId:u.media_id] delegateHandle:nil];

  return self;
}

- (long) compareTo:(User *)ob
{
    return self.user_id == ob.user_id;
}

- (NSString *) name
{
    return self.display_name;
}

- (long) icon_media_id
{
    return 126853;
}

@end

