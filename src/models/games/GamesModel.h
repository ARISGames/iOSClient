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
- (NSArray *) anywhereGames;
- (NSArray *) popularGames;
- (NSArray *) recentGames;
- (NSArray *) searchGames:(NSString *)search;

- (void) invalidateData; //force refresh
- (void) clearData;

@end
