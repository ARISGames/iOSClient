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

- (Game *) gameForId:(int)game_id;
- (void) requestGame:(int)game_id;

- (NSArray *) nearbyGames;
- (NSArray *) pingNearbyGames;

- (NSArray *) anywhereGames;
- (NSArray *) pingAnywhereGames;

- (NSArray *) popularGames;
- (NSArray *) pingPopularGames;

- (NSArray *) recentGames;
- (NSArray *) pingRecentGames;

- (NSArray *) searchGames;
- (NSArray *) pingSearchGames:(NSString *)search;

- (void) requestPlayerPlayedGame:(int)game_id;
- (void) playerResetGame:(int)game_id;

- (void) invalidateData; //force refresh
- (void) clearData;

@end
