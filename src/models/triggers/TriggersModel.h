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

- (Trigger *) triggerForId:(int)trigger_id;
- (Trigger *) triggerForQRCode:(NSString *)code;
- (NSArray *) playerTriggers;
- (void) requestTriggers;
- (void) requestPlayerTriggers;

- (void) clearPlayerData;
- (void) clearGameData;

@end
