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
- (void) requestMaintenanceData { }
- (void) requestPlayerData { }
- (void) clearGameData { [self clearPlayerData]; }
- (void) clearPlayerData { }

- (long) nGameDataToReceive { return 0; }
- (long) nMaintenanceDataToReceive { return 0; }
- (long) nPlayerDataToReceive { return 0; }

- (long) nGameDataReceived
{
  if(n_game_data_received > [self nGameDataToReceive]) return [self nGameDataToReceive];
  return n_game_data_received;
}
- (long) nMaintenanceDataReceived
{
  if(n_maintenance_data_received > [self nMaintenanceDataToReceive]) return [self nMaintenanceDataToReceive];
  return n_maintenance_data_received;
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
- (BOOL) maintenanceDataReceived
{
  return n_maintenance_data_received >= [self nMaintenanceDataToReceive];
}
- (BOOL) playerDataReceived
{
  return n_player_data_received >= [self nPlayerDataToReceive];
}

- (NSString *) serializedName
{
  return @"aris";
}

- (NSString *) serializeGameData
{
  return @"";
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  n_game_data_received = [self nGameDataToReceive];
}

- (NSString *) serializePlayerData
{
  return @"";
}

- (void) deserializePlayerData:(NSString *)data
{
  [self clearPlayerData];
  n_player_data_received = [self nPlayerDataToReceive];
}

@end

