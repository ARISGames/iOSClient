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

@implementation WebPage

@synthesize web_page_id;
@synthesize name;
@synthesize url;
@synthesize icon_media_id;
@synthesize enable_back_button;

- (id) init
{
    if(self = [super init])
    {
        self.web_page_id = 0;
        self.name = @"WebPage";
        self.url = @"http://www.arisgames.org";
        self.icon_media_id = 0;
        self.enable_back_button = 0;
    }
    return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.web_page_id        = [dict validIntForKey:@"web_page_id"];
        self.name               = [dict validObjectForKey:@"name"];
        self.url                = [dict validObjectForKey:@"url"];
        self.icon_media_id      = [dict validIntForKey:@"icon_media_id"];
        self.enable_back_button = [dict validBoolForKey:@"enable_back_button"];
    }
    return self;
}

- (id) copy
{
    WebPage *c = [[WebPage alloc] init];
    c.web_page_id = self.web_page_id;
    c.name = self.name;
    c.url = self.url;
    c.icon_media_id = self.icon_media_id;
    c.enable_back_button = self.enable_back_button;
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
