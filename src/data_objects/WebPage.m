//
//  WebPage.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"
#import "Media.h"
#import "NSDictionary+ValidParsers.h"
#import "NSString+JSON.h"

@implementation WebPage

@synthesize web_page_id;
@synthesize name;
@synthesize url;
@synthesize icon_media_id;
@synthesize back_button_enabled;

- (id) init
{
  if(self = [super init])
  {
    self.web_page_id = 0;
    self.name = @"WebPage";
    self.url = @"http://www.arisgames.org";
    self.icon_media_id = 0;
    self.back_button_enabled = YES;
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
  if(self = [super init])
  {
    self.web_page_id         = [dict validIntForKey:@"web_page_id"];
    self.name                = [dict validStringForKey:@"name"];
    self.url                 = [dict validStringForKey:@"url"];
    self.icon_media_id       = [dict validIntForKey:@"icon_media_id"];
    self.back_button_enabled = [dict validBoolForKey:@"back_button_enabled"];
  }
  return self;
}

- (NSString *) serialize
{
  NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
  [d setObject:[NSString stringWithFormat:@"%ld",self.web_page_id] forKey:@"web_page_id"];
  [d setObject:self.name forKey:@"name"];
  [d setObject:self.url forKey:@"url"];
  [d setObject:[NSString stringWithFormat:@"%ld",self.icon_media_id] forKey:@"icon_media_id"];
  [d setObject:[NSString stringWithFormat:@"%d",self.back_button_enabled] forKey:@"back_button_enabled"];
  return [NSString JSONFromFlatStringDict:d];
}

- (id) copy
{
  WebPage *c = [[WebPage alloc] init];
  c.web_page_id = self.web_page_id;
  c.name = self.name;
  c.url = self.url;
  c.icon_media_id = self.icon_media_id;
  c.back_button_enabled = self.back_button_enabled;
  return c;
}

- (long) compareTo:(WebPage *)ob
{
  return (ob.web_page_id == self.web_page_id);
}

- (NSString *) description
{
  return [NSString stringWithFormat:@"WebPage- Id:%ld\tName:%@\tURL:%@\t",self.web_page_id,self.name,self.url];
}

- (long) icon_media_id
{
  if(!icon_media_id) return DEFAULT_WEB_PAGE_ICON_MEDIA_ID;
  return icon_media_id;
}

@end

