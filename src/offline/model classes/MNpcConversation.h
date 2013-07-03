//
//  MNpcConversation.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/19/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MNode, MNpc;

@interface MNpcConversation : NSManagedObject

@property (nonatomic, retain) NSNumber * conversationId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) MNpc *npc;
@property (nonatomic, retain) MNode *node;
@property (nonatomic, retain) MGame *game;

@end
