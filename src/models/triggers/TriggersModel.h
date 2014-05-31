//
//  TriggersModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Trigger.h"

@interface TriggersModel : NSObject

- (Trigger *) instanceForId:(int)instance_id;
- (NSArray *) playerTriggers;
- (void) requestTriggers;
- (void) requestPlayerTriggers;

- (void) clearPlayerData;
- (void) clearGameData;

@end
