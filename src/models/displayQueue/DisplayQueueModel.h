//
//  DisplayQueueModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/24/14.
//
//

#import <Foundation/Foundation.h>
@class Trigger;

@protocol DisplayQueueModelDelegate
- (BOOL) displayTrigger:(Trigger *)t;
@end

@interface DisplayQueueModel : NSObject

- (id) initWithDelegate:(id<DisplayQueueModelDelegate>)d;
- (void) enqueueTrigger:(Trigger *)t;
- (void) dequeueTrigger;

@end
