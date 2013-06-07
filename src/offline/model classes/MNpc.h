//
//  MNpc.h
//  ARIS
//
//  Created by Miodrag Glumac on 2/20/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MMedia, MNpcConversation;

@interface MNpc : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * closing;
@property (nonatomic, retain) NSNumber * npcId;
@property (nonatomic, retain) NSString * npcDescription;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) MGame *game;
@property (nonatomic, retain) MMedia *media;
@property (nonatomic, retain) MMedia *icon;
@property (nonatomic, retain) NSOrderedSet *conversations;
@end

@interface MNpc (CoreDataGeneratedAccessors)

- (void)insertObject:(MNpcConversation *)value inConversationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromConversationsAtIndex:(NSUInteger)idx;
- (void)insertConversations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeConversationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInConversationsAtIndex:(NSUInteger)idx withObject:(MNpcConversation *)value;
- (void)replaceConversationsAtIndexes:(NSIndexSet *)indexes withConversations:(NSArray *)values;
- (void)addConversationsObject:(MNpcConversation *)value;
- (void)removeConversationsObject:(MNpcConversation *)value;
- (void)addConversations:(NSOrderedSet *)values;
- (void)removeConversations:(NSOrderedSet *)values;
@end
