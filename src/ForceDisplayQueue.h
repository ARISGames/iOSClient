//
//  ForceDisplayQueue.h
//  ARIS
//
//  Created by Phil Dougherty on 2/24/14.
//
//

#import <Foundation/Foundation.h>

@protocol StateControllerProtocol;

@protocol ForceDisplayQueueDelegate
@end

@interface ForceDisplayQueue : NSObject

- (id) initWithDelegate:(id<ForceDisplayQueueDelegate, StateControllerProtocol>)d;
- (void) forceDisplayEligibleLocations;

@end
