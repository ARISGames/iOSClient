//
//  TabsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Tab.h"

@interface TabsModel : NSObject

- (Tab *) tabForId:(long)tab_id;
- (Tab *) tabForType:(NSString *)t;
- (NSArray *) playerTabs;
- (void) requestTabs;
- (void) requestPlayerTabs;

- (void) clearPlayerData;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end
