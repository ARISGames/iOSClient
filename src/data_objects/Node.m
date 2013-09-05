//
//  Node.m
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Node.h"
#import "NodeViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Node

@synthesize nodeId;
@synthesize name;
@synthesize text;
@synthesize mediaId;
@synthesize iconMediaId;

- (Node *) init
{
    if(self = [super init])
    {
        self.nodeId = 0;
        self.name = @"Node";
        self.text = @"Text";
        self.mediaId = 0;
        self.iconMediaId = 0;
    }
    return self;	
}

- (Node *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.nodeId      = [dict validIntForKey:@"node_id"];
        self.name        = [dict validObjectForKey:@"title"];
        self.text        = [dict validObjectForKey:@"text"];
        self.mediaId     = [dict validIntForKey:@"media_id"];
        self.iconMediaId = [dict validIntForKey:@"icon_media_id"];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectNode;
}

- (NodeViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate> *)d fromSource:(id)s
{
    return [[NodeViewController alloc] initWithNode:self delegate:d];
}

- (Node *) copy
{
    Node *c = [[Node alloc] init];
    c.nodeId = self.nodeId;
    c.name = self.name;
    c.text = self.text;
    c.mediaId = self.mediaId;
    c.iconMediaId = self.iconMediaId;
    return c;
}

- (int) compareTo:(Node *)ob
{
	return (ob.nodeId == self.nodeId);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Node- Id:%d\tName:%@\tText:%@\t",self.nodeId,self.name,self.text];
}

@end
