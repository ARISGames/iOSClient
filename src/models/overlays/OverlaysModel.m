//
//  OverlaysModel.m
//  ARIS
//
//  Created by Justin Moeller on 3/7/14.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "OverlaysModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface OverlaysModel()
{
  NSMutableDictionary *overlays;
  NSArray *playerOverlays;
}
@end

@implementation OverlaysModel

- (id) init
{
  if (self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_OVERLAYS_RECEIVED",self,@selector(overlaysReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_OVERLAYS_RECEIVED",self,@selector(playerOverlaysReceived:),nil);
  }
  return self;
}

- (void) requestPlayerData
{
  [self requestPlayerOverlays];
}
- (void) clearPlayerData
{
  playerOverlays = [[NSArray alloc] init];
  n_player_data_received = 0;
}
- (long) nPlayerDataToReceive
{
  return 1;
}

- (void) requestGameData
{
  [self requestOverlays];
}
- (void) clearGameData
{
  [self clearPlayerData];
  overlays = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) overlaysReceived:(NSNotification *)notif
{
  [self updateOverlays:notif.userInfo[@"overlays"]];
}

- (void) updateOverlays:(NSArray *)newOverlays
{
  Overlay *newOverlay;
  NSNumber *newOverlayId;
  for(long i = 0; i < newOverlays.count; i++)
  {
    newOverlay = [newOverlays objectAtIndex:i];
    newOverlayId = [NSNumber numberWithLong:newOverlay.overlay_id];
    if(![overlays objectForKey:newOverlayId])
      [overlays setObject:newOverlay forKey:newOverlayId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_OVERLAYS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (NSArray *) conformOverlaysListToFlyweight:(NSArray *)newOverlays
{
  NSMutableArray *conformingOverlays = [[NSMutableArray alloc] init];
  Overlay *o;
  for(long i = 0; i < newOverlays.count; i++)
  {
    if((o = [self overlayForId:((Overlay *)newOverlays[i]).overlay_id]))
      [conformingOverlays addObject:o];
  }
  
  return conformingOverlays;
}

- (void) playerOverlaysReceived:(NSNotification *)notif
{
  [self updatePlayerOverlays:[self conformOverlaysListToFlyweight:notif.userInfo[@"overlays"]]];
}

- (void) updatePlayerOverlays:(NSArray *)newOverlays
{
  NSMutableArray *addedOverlays = [[NSMutableArray alloc] init];
  NSMutableArray *removedOverlays = [[NSMutableArray alloc] init];
  
  //placeholders for comparison
  Overlay *newOverlay;
  Overlay *oldOverlay;
  
  //find added
  BOOL new;
  for(long i = 0; i < newOverlays.count; i++)
  {
    new = YES;
    newOverlay = newOverlays[i];
    for(long j = 0; j < playerOverlays.count; j++)
    {
      oldOverlay = playerOverlays[j];
      if(newOverlay.overlay_id == oldOverlay.overlay_id) new = NO;
    }
    if(new) [addedOverlays addObject:newOverlays[i]];
  }
  
  //find removed
  BOOL removed;
  for(long i = 0; i < playerOverlays.count; i++)
  {
    removed = YES;
    oldOverlay = playerOverlays[i];
    for(long j = 0; j < newOverlays.count; j++)
    {
      newOverlay = newOverlays[j];
      if(newOverlay.overlay_id == oldOverlay.overlay_id) removed = NO;
    }
    if(removed) [removedOverlays addObject:playerOverlays[i]];
  }
  
  playerOverlays = newOverlays;
  n_player_data_received++;
  if(addedOverlays.count > 0)   _ARIS_NOTIF_SEND_(@"MODEL_OVERLAYS_NEW_AVAILABLE",nil,@{@"added":addedOverlays});
  if(removedOverlays.count > 0) _ARIS_NOTIF_SEND_(@"MODEL_OVERLAYS_LESS_AVAILABLE",nil,@{@"removed":removedOverlays});
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PLAYER_PIECE_AVAILABLE",nil,nil);
}

- (void) requestOverlays       { [_SERVICES_ fetchOverlays];   }
- (void) requestPlayerOverlays
{
  if([self playerDataReceived] &&
     ![_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  {
    NSMutableArray *ptrigs = [[NSMutableArray alloc] init];
    /*
     // copied impl from triggers- haven't yet actually designed overlays...
    NSArray *os = [overlays allValues];
    for(int i = 0; i < os.count; i++)
    {
      Overlay *o = os[i];
      if([_MODEL_REQUIREMENTS_ evaluateRequirementRoot:o.requirement_root_package_id])
        [ptrigs addObject:o];
    }
     */
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_OVERLAYS_RECEIVED",nil,@{@"triggers":ptrigs});
  }
  if(![self playerDataReceived] ||
     [_MODEL_GAME_.network_level isEqualToString:@"HYBRID"] ||
     [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
  [_SERVICES_ fetchOverlaysForPlayer];
}

- (Overlay *) overlayForId:(long)overlay_id
{
  return [overlays objectForKey:[NSNumber numberWithLong:overlay_id]];
}

- (NSArray *) playerOverlays
{
  return playerOverlays;
}

- (NSString *) serializeModel
{
  return @"";
}

- (void) deserializeModel:(NSString *)data
{

}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

