//
//  ARISModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#include "ARISModel.h"

@implementation ARISModel

- (void) requestGameData { }
- (void) requestPlayerData { }
- (void) clearGameData { [self clearPlayerData]; }
- (void) clearPlayerData { }

- (long) nGameDataToReceive { return 0; }
- (long) nPlayerDataToReceive { return 0; }

- (long) nGameDataReceived
{
  if(n_game_data_received > [self nGameDataToReceive]) return [self nGameDataToReceive];
  return n_game_data_received;
}
- (long) nPlayerDataReceived
{
  if(n_player_data_received > [self nPlayerDataToReceive]) return [self nPlayerDataToReceive];
  return n_player_data_received;
}

- (BOOL) gameDataReceived
{
  return n_game_data_received >= [self nGameDataToReceive];
}
- (BOOL) playerDataReceived
{
  return n_player_data_received >= [self nPlayerDataToReceive];
}

- (NSString *) serializedName
{
  return @"aris";
}

- (NSString *) serializeModel
{
  return @"";
}

- (void) deserializeModel:(NSString *)data
{

}

@end

