//
//  DisplayQueue.h
//  ARIS
//
//  Created by Phil Dougherty on 2/24/14.
//
//

#import <Foundation/Foundation.h>
@class Trigger;

@protocol DisplayQueueDelegate
- (BOOL) displayTrigger:(Trigger *)t;
@end

@interface DisplayQueue : NSObject

- (id) initWithDelegate:(id<DisplayQueueDelegate>)d;
- (void) enqueueTrigger:(Trigger *)t;
- (void) dequeueTrigger;

@end
