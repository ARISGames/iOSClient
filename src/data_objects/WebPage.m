//
//  WebPage.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"
#import "NSDictionary+ValidParsers.h"

@implementation WebPage

@synthesize web_page_id;
@synthesize name;
@synthesize url;
@synthesize icon_media_id;

- (id) init
{
    if(self = [super init])
    {
        self.web_page_id = 0;
        self.name = @"WebPage";
        self.url = @"http://www.arisgames.org";
        self.icon_media_id = 0;
    }
    return self;	
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.web_page_id   = [dict validIntForKey:@"web_page_id"];
        self.name        = [dict validObjectForKey:@"name"];
        self.url         = [dict validObjectForKey:@"url"];
        self.icon_media_id = [dict validIntForKey:@"icon_media_id"];
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
    return c;
}

- (int)compareTo:(WebPage *)ob
{
	return (ob.web_page_id == self.web_page_id);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"WebPage- Id:%d\tName:%@\tURL:%@\t",self.web_page_id,self.name,self.url];
}

@end
