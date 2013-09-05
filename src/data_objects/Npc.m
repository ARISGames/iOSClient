//
//  NPC.m
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Npc.h"
#import "NpcViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Npc

@synthesize npcId;
@synthesize name;
@synthesize greeting;
@synthesize closing;
@synthesize mediaId;
@synthesize iconMediaId;

- (Npc *) init
{
	self = [super init];
    if(self)
    {
        self.npcId = 0;
        self.name = @"Npc";
        self.greeting = @"Greeting";
        self.closing = @"Closing";
        self.mediaId = 0;
        self.iconMediaId = 0;
    }
    return self;	
}

- (Npc *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.npcId       = [dict validIntForKey:@"npc_id"];
        self.name        = [dict validObjectForKey:@"name"];
        self.greeting    = [dict validObjectForKey:@"text"];
        self.closing     = [dict validStringForKey:@"closing"];
        self.mediaId     = [dict validIntForKey:@"media_id"];
        self.iconMediaId = [dict validIntForKey:@"icon_media_id"];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectNpc;
}

- (NpcViewController *) viewControllerForDelegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d fromSource:(id)s
{
	return [[NpcViewController alloc] initWithNpc:self delegate:d];
}

-(Npc *)copy
{
    Npc *c = [[Npc alloc] init];
    c.npcId = self.npcId;
    c.name = self.name;
    c.greeting = self.greeting;
    c.closing = self.closing;
    c.mediaId = self.mediaId;
    c.iconMediaId = self.iconMediaId;
    return c;
}

- (int)compareTo:(Npc *)ob
{
	return (ob.npcId == self.npcId);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Npc- Id:%d\tName:%@\t",self.npcId,self.name];
}

@end
