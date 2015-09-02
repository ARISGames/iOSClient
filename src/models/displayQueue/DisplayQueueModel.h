//
//  DisplayQueueModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/24/14.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"

@class Trigger;
@class Instance;
@protocol InstantiableProtocol;
@class Tab;

@interface DisplayQueueModel : ARISModel

- (void) clearPlayerData;

- (void) enqueueTrigger:(Trigger *)t;
- (void) injectTrigger:(Trigger *)t;
- (void) enqueueInstance:(Instance *)i;
- (void) injectInstance:(Instance *)i;
- (void) enqueueObject:(NSObject <InstantiableProtocol>*)o;
- (void) injectObject:(NSObject <InstantiableProtocol>*)o;
- (void) enqueueTab:(Tab *)t;
- (void) injectTab:(Tab *)t;

- (NSObject *) dequeue;

@end
