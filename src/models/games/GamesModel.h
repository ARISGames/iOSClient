//
//  GamesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface GamesModel : NSObject

- (Game *) gameForId:(long)game_id;
- (void) requestGame:(long)game_id;

- (NSArray *) nearbyGames;
- (NSArray *) pingNearbyGames;

- (NSArray *) anywhereGames;
- (NSArray *) pingAnywhereGames;

- (NSArray *) popularGames;
- (NSArray *) pingPopularGames:(NSString *)interval;

- (NSArray *) recentGames;
- (NSArray *) pingRecentGames;

- (NSArray *) searchGames;
- (NSArray *) pingSearchGames:(NSString *)search;

- (NSArray *) mineGames;
- (NSArray *) pingMineGames;

- (void) requestPlayerPlayedGame:(long)game_id;
- (void) playerResetGame:(long)game_id;

- (void) invalidateData; //force refresh
- (void) clearData;

@end
