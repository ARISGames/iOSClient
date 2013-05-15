//
//  WebPage.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"
#import "WebPageViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation WebPage

@synthesize webPageId;
@synthesize name;
@synthesize url;
@synthesize iconMediaId;

- (WebPage *) init
{
    if(self = [super init])
    {
        self.webPageId = 0;
        self.name = @"WebPage";
        self.url = @"http://www.arisgames.org";
        self.iconMediaId = 0;
    }
    return self;	
}

- (WebPage *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.webPageId   = [dict validIntForKey:@"web_page_id"];
        self.name        = [dict validObjectForKey:@"name"];
        self.url         = [dict validObjectForKey:@"url"];
        self.iconMediaId = [dict validIntForKey:@"icon_media_id"];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectWebPage;
}

- (WebPageViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate> *)d fromSource:(id)s
{
	return [[WebPageViewController alloc] initWithWebPage:self delegate:d];
}

-(WebPage *)copy
{
    WebPage *c = [[WebPage alloc] init];
    c.webPageId = self.webPageId;
    c.name = self.name;
    c.url = self.url;
    c.iconMediaId = self.iconMediaId;
    return c;
}

- (int)compareTo:(WebPage *)ob
{
	return (ob.webPageId == self.webPageId);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"WebPage- Id:%d\tName:%@\tURL:%@\t",self.webPageId,self.name,self.url];
}

@end
