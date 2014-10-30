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
- (NSArray *) instancesForType:(NSString *)object_type id:(int)object_id;

- (NSArray *) playerInstances;
- (void) requestInstances;
- (void) requestPlayerInstances;

- (void) clearPlayerData;
- (void) clearGameData;

@end
