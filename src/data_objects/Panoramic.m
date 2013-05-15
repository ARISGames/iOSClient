//
//  Panoramic.m
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Panoramic.h"
#import "PanoramicViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Panoramic

@synthesize panoramicId;
@synthesize name;
@synthesize iconMediaId;
@synthesize mediaId;

- (Panoramic *) init
{
    if (self = [super init])
    {
        self.panoramicId = 0;
        self.name = @"Panoramic";
        self.iconMediaId = 0;
        self.mediaId = 364;
    }
    return self;	
}

- (Panoramic *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.panoramicId  = [dict validIntForKey:@"aug_bubble_id"];
        self.name         = [dict validObjectForKey:@"name"];
        self.iconMediaId  = [dict validIntForKey:@"icon_media_id"];
        if([((NSArray *)[dict validObjectForKey:@"media"]) count] > 0)
            self.mediaId = [[((NSArray *)[dict validObjectForKey:@"media"]) objectAtIndex:0] validIntForKey:@"media_id"];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectPanoramic;
}

- (PanoramicViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate> *)d fromSource:(id)s
{
	return [[PanoramicViewController alloc] initWithPanoramic:self delegate:d];
}

- (Panoramic *) copy
{
    Panoramic *c = [[Panoramic alloc] init];
    c.panoramicId = self.panoramicId;
    c.name = self.name;
    c.iconMediaId = self.iconMediaId;
    c.mediaId = self.mediaId;
    return c;
}

- (int) compareTo:(Panoramic *)ob
{
	return (ob.panoramicId == self.panoramicId);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Panoramic- Id:%d\tName:%@\t",self.panoramicId,self.name];
}

@end
