//
//  TriggersModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Trigger.h"

@interface TriggersModel : ARISModel

- (Trigger *) triggerForId:(long)trigger_id;
- (Trigger *) triggerForQRCode:(NSString *)code;
- (NSArray *) triggersForInstanceId:(long)instance_id;

- (NSArray *) playerTriggers;
- (void) requestTriggers;
- (void) requestPlayerTriggers;

//odd one-off function
- (void) expireTriggersForInstanceId:(long)instance_id;

@end

