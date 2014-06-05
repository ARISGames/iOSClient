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

- (Tab *) tabForId:(int)tab_id;
- (NSArray *) visibleTabs;
- (void) requestTabs;
- (void) requestPlayerTabs;

- (void) clearPlayerData;
- (void) clearGameData;

@end
