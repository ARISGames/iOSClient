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
    
  //blacklist triggered triggers from auto-enqueue until they become unavailable for at least one refresh
  //(prevents constant triggering if somone has bad requirements)
  NSMutableArray *triggerBlacklist;
    
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
    triggerBlacklist = [[NSMutableArray alloc] init];
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_NEW_AVAILABLE",self,@selector(enqueueNewImmediates),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_LESS_AVAILABLE",self,@selector(purgeInvalidFromQueue),nil);
  }
  return self;
}

- (void) enqueueTrigger:(Trigger *)t
{
  if(![self triggerInQueue:t])
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
    if([delegate displayTrigger:t])
    {
        [triggerQueue removeObject:t];
        [triggerBlacklist addObject:t];
    }
  }
}

- (BOOL) triggerInQueue:(Trigger *)t
{
  for(int i = 0; i < triggerQueue.count; i++)
    if(t == triggerQueue[i]) return YES;
  return NO;
}

- (BOOL) triggerBlacklisted:(Trigger *)t
{
  for(int i = 0; i < triggerBlacklist.count; i++)
    if(t == triggerBlacklist[i]) return YES;
  return NO;
}

- (void) purgeInvalidFromQueue
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;
    
  //if trigger in queue no longer available, remove from queue
  for(int i = 0; i < triggerQueue.count; i++)
  {
    BOOL valid = NO;
    t = triggerQueue[i];
    for(int j = 0; j < pt.count; j++)
      if(t == pt[j]) valid = YES;
    if(!valid) [triggerQueue removeObject:t];
  }
    
  //if trigger in blacklist no longer available/within range, remove from blacklist
  for(int i = 0; i < triggerBlacklist.count; i++)
  {
    BOOL valid = NO;
    t = triggerBlacklist[i];
    for(int j = 0; j < pt.count; j++)
      if(t == pt[j] && ([t.type isEqualToString:@"IMMEDIATE"] || ([t.type isEqualToString:@"LOCATION"] && t.trigger_on_enter && [t.location distanceFromLocation:_MODEL_PLAYER_.location] < t.distance))) valid = YES;
    if(!valid) [triggerBlacklist removeObject:t];
  }
}

- (void) enqueueNewImmediates
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;
  for(int i = 0; i < pt.count; i++)
  {
    t = pt[i];
    if(([t.type isEqualToString:@"IMMEDIATE"] || ([t.type isEqualToString:@"LOCATION"] && t.trigger_on_enter && [t.location distanceFromLocation:_MODEL_PLAYER_.location] < t.distance)) 
       && ![self triggerBlacklisted:t])
      [self enqueueTrigger:t]; //will auto verify not already in queue
  }
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);   
}

@end
