//
//  InstancesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Instance.h"

@interface InstancesModel : NSObject

- (Instance *) instanceForId:(int)instance_id;
- (NSArray *) playerInstances;
- (void) requestGameInstances;
- (void) requestPlayerInstances;

- (void) clearPlayerData;
- (void) clearGameData;

@end
