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

- (Instance *) instanceForId:(long)instance_id;
- (NSArray *) instancesForType:(NSString *)object_type id:(long)object_id;

- (long) setQtyForInstanceId:(long)instance_id qty:(long)qty;
- (NSArray *) playerInstances;
- (NSArray *) gameOwnedInstances;
- (NSArray *) groupOwnedInstances;
- (void) requestInstances;
- (void) requestPlayerInstances; //game-owned fits in this category

- (void) clearPlayerData; //game-owned fits in this category
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end
