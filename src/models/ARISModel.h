//
//  ARISModel.h
//  ARIS
//
//  Created by Ben Longoria on 2/17/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARISModel : NSObject
{
  long n_game_data_received;
  long n_maintenance_data_received;
  long n_player_data_received;
}

- (void) requestGameData;
- (void) requestMaintenanceData;
- (void) requestPlayerData;

- (void) clearGameData;
- (void) clearPlayerData;

- (long) nGameDataToReceive;
- (long) nMaintenanceDataToReceive;
- (long) nPlayerDataToReceive;
- (long) nGameDataReceived;
- (long) nMaintenanceDataReceived;
- (long) nPlayerDataReceived;

- (BOOL) gameDataReceived;
- (BOOL) maintenanceDataReceived;
- (BOOL) playerDataReceived;

- (NSString *) serializedName;
- (NSString *) serializeGameData;
- (void) deserializeGameData:(NSString *)data;
- (NSString *) serializePlayerData;
- (void) deserializePlayerData:(NSString *)data;

@end

