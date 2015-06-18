//
//  EventsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "EventsModel.h"
#import "AppModel.h"
#import "AppServices.h"

@interface EventsModel()
{
    NSMutableDictionary *events;
    long game_info_recvd;
}

@end

@implementation EventsModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_EVENTS_RECEIVED",self,@selector(eventsReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    events = [[NSMutableDictionary alloc] init];
    game_info_recvd = 0;
}

- (BOOL) gameInfoRecvd
{
  return game_info_recvd >= 1;
}

- (void) eventsReceived:(NSNotification *)notif
{
    [self updateEvents:[notif.userInfo objectForKey:@"events"]];
}

- (void) updateEvents:(NSArray *)newEvents
{
    Event *newEvent;
    NSNumber *newEventId;
    for(long i = 0; i < newEvents.count; i++)
    {
      newEvent = [newEvents objectAtIndex:i];
      newEventId = [NSNumber numberWithLong:newEvent.event_id];
      if(![events objectForKey:newEventId]) [events setObject:newEvent forKey:newEventId];
    }
    game_info_recvd++;
    _ARIS_NOTIF_SEND_(@"MODEL_EVENTS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) runEventPackageId:(long)event_package_id
{
    NSArray *es = [self eventsForEventPackageId:event_package_id];
    Event *e;
    for(long i = 0; i < es.count; i++)
    {
        e = es[i];
        //legacy
        if([e.event isEqualToString:@"TAKE_ITEM"])
            [_MODEL_PLAYER_INSTANCES_ takeItemFromPlayer:e.content_id qtyToRemove:e.qty];
        if([e.event isEqualToString:@"GIVE_ITEM"])
            [_MODEL_PLAYER_INSTANCES_ giveItemToPlayer:e.content_id qtyToAdd:e.qty];
      
        if(!e.event || [e.event isEqualToString:@"NONE"])
          return;
      
        if([e.event isEqualToString:@"TAKE_ITEM_PLAYER"])
            [_MODEL_PLAYER_INSTANCES_ takeItemFromPlayer:e.content_id qtyToRemove:e.qty];
        if([e.event isEqualToString:@"GIVE_ITEM_PLAYER"])
            [_MODEL_PLAYER_INSTANCES_ giveItemToPlayer:e.content_id qtyToAdd:e.qty];
        if([e.event isEqualToString:@"SET_ITEM_PLAYER"])
            [_MODEL_PLAYER_INSTANCES_ setItemsForPlayer:e.content_id qtyToSet:e.qty];
      
        if([e.event isEqualToString:@"TAKE_ITEM_GAME"])
            [_MODEL_GAME_INSTANCES_ takeItemFromGame:e.content_id qtyToRemove:e.qty];
        if([e.event isEqualToString:@"GIVE_ITEM_GAME"])
            [_MODEL_GAME_INSTANCES_ giveItemToGame:e.content_id qtyToAdd:e.qty];
        if([e.event isEqualToString:@"SET_ITEM_GAME"])
            [_MODEL_GAME_INSTANCES_ setItemsForGame:e.content_id qtyToSet:e.qty];
      
        if([e.event isEqualToString:@"TAKE_ITEM_GROuP"])
            [_MODEL_GROUP_INSTANCES_ takeItemFromGroup:e.content_id qtyToRemove:e.qty];
        if([e.event isEqualToString:@"GIVE_ITEM_GROUP"])
            [_MODEL_GROUP_INSTANCES_ giveItemToGroup:e.content_id qtyToAdd:e.qty];
        if([e.event isEqualToString:@"SET_ITEM_GROUP"])
            [_MODEL_GROUP_INSTANCES_ setItemsForGroup:e.content_id qtyToSet:e.qty];
      
        if([e.event isEqualToString:@"SET_SCENE"])
          [_MODEL_SCENES_ setPlayerScene:[_MODEL_SCENES_ sceneForId:e.content_id]];
      
        /* NEEDS IMPL
        if([e.event isEqualToString:@"SET_GROUP"])
          //?
        */
    }
    [_MODEL_LOGS_ playerRanEventPackageId:event_package_id];
}

- (void) requestEvents
{
    [_SERVICES_ fetchEvents];
}

- (NSArray *) eventsForEventPackageId:(long)event_package_id
{
    Event *e;
    NSMutableArray *package_events = [[NSMutableArray alloc] init];
    NSArray *allEvents = [events allValues];
    for(long i = 0; i < allEvents.count; i++)
    {
        e = allEvents[i];
        if(e.event_package_id == event_package_id)
            [package_events addObject:e];
    }
    return package_events;
}

- (NSArray *) events
{
    return [events allValues];
}

// null event (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Event *) eventForId:(long)event_id
{
  if(!event_id) return [[Event alloc] init];
  return [events objectForKey:[NSNumber numberWithLong:event_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
