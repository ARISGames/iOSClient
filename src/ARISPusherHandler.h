//
//  ARISPusherHandler.h
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import <Foundation/Foundation.h>

@interface ARISPusherHandler : NSObject

+ (ARISPusherHandler *) sharedPusherHandler;

- (void) loginGame:(int)gameId;
- (void) loginPlayer:(int)user_id;
- (void) loginGroup:(NSString *)group;
- (void) loginWebPage:(int)webPageId;

- (void) logoutGame;
- (void) logoutPlayer;
- (void) logoutGroup;
- (void) logoutWebPage;

@end
