//
//  DisplayQueueModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/24/14.
//
//

#import "DisplayQueueModel.h"
#import "AppModel.h"

@interface DisplayQueueModel ()
{
  NSMutableArray *triggerQueue;
  id<DisplayQueueModelDelegate> __unsafe_unretained delegate;
}
@end

@implementation DisplayQueueModel

- (id) initWithDelegate:(id<DisplayQueueModelDelegate>)d
{
  if(self = [super init])
  {
    delegate = d;
    triggerQueue = [[NSMutableArray alloc] init];
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_NEW_AVAILABLE",self,@selector(enqueueNewImmediates),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_LESS_AVAILABLE",self,@selector(purgeInvalidFromQueue),nil);
  }
  return self;
}

- (void) enqueueTrigger:(Trigger *)t
{
  if([self verifyNotInQueue:t])
    [triggerQueue addObject:t];
  [self dequeueTrigger];
}

- (void) dequeueTrigger
{
  [self purgeInvalidFromQueue];
  Trigger *t;
  if(triggerQueue.count > 0)
  {
    t = triggerQueue[0];
    if([delegate displayTrigger:t]) [triggerQueue removeObject:t];
  }
}

- (BOOL) verifyNotInQueue:(Trigger *)t
{
  for(int i = 0; i < triggerQueue.count; i++)
    if(t == triggerQueue[i]) return NO;
  return YES;
}

- (void) purgeInvalidFromQueue
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  for(int i = 0; i < triggerQueue.count; i++)
  {
    BOOL valid = NO;
    for(int j = 0; j < pt.count; j++)
      if(triggerQueue[i] == pt[j]) valid = YES;
    if(!valid) [triggerQueue removeObject:triggerQueue[i]];
  }
}

- (void) enqueueNewImmediates
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;
  for(int i = 0; i < pt.count; i++)
  {
    t = pt[i];
    if([t.type isEqualToString:@"IMMEDIATE"] || ([t.type isEqualToString:@"LOCATION"] && t.trigger_on_enter && [t.location distanceFromLocation:_MODEL_PLAYER_.location] < t.distance))
      [self enqueueTrigger:t]; //will auto verify not already in queue
  }
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);   
}

@end
