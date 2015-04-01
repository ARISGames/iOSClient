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
        if([e.event isEqualToString:@"TAKE_ITEM"])
            [_MODEL_PLAYER_INSTANCES_ takeItemFromPlayer:e.content_id qtyToRemove:e.qty];
        if([e.event isEqualToString:@"GIVE_ITEM"])
            [_MODEL_PLAYER_INSTANCES_ giveItemToPlayer:e.content_id qtyToAdd:e.qty];
    }
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
