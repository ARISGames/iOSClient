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
#import "ARISWebView.h"
#import "SBJson.h"

@interface EventsModel() <ARISWebViewDelegate>
{
  NSMutableDictionary *events;
  ARISWebView *runner; //only running one at once
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

- (void) requestGameData
{
  [self requestEvents];
}
- (void) clearGameData
{
  events = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
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
  n_game_data_received++;
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

    if([e.event isEqualToString:@"SET_GROUP"])
      [_MODEL_GROUPS_ setPlayerGroup:[_MODEL_GROUPS_ groupForId:e.content_id]];

    if([e.event isEqualToString:@"RUN_SCRIPT"])
    {
      runner = [[ARISWebView alloc] initWithDelegate:self];
      runner.userInteractionEnabled = NO;
      [runner loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], e.script] baseURL:nil];
    }
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

// NOT flyweight!!! (because joke objects)
- (EventPackage *) eventPackageForId:(long)event_package_id
{
  EventPackage *ep = [[EventPackage alloc] init];
  ep.event_package_id = event_package_id;
  return ep;
}

- (NSString *) serializedName
{
  return @"events";
}

- (NSString *) serializeGameData
{
  NSArray *events_a = [events allValues];
  Event *e_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"events\":["];
  for(long i = 0; i < events_a.count; i++)
  {
    e_o = events_a[i];
    [r appendString:[e_o serialize]];
    if(i != events_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_events = d_data[@"events"];
  for(long i = 0; i < d_events.count; i++)
  {
    Event *e = [[Event alloc] initWithDictionary:d_events[i]];
    [events setObject:e forKey:[NSNumber numberWithLong:e.event_id]];
  }
}

- (NSString *) serializePlayerData
{
  return @"";
}

- (void) deserializePlayerData:(NSString *)data
{

}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
