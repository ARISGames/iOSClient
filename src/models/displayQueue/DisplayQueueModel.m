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
  NSMutableArray *displayQueue;

  //blacklist triggered triggers from auto-enqueue until they become unavailable for at least one refresh
  //(prevents constant triggering if somone has bad requirements)
  NSMutableArray *displayBlacklist;
  NSTimer *timerPoller;
}
@end

@implementation DisplayQueueModel

- (id) init
{
  if(self = [super init])
  {
    timerPoller = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickAndEnqueueAvailableTimers) userInfo:nil repeats:YES];
    [self clearPlayerData];
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_NEW_AVAILABLE",self,@selector(reevaluateAutoTriggers),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_LESS_AVAILABLE",self,@selector(reevaluateAutoTriggers),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_INVALIDATED",self,@selector(reevaluateAutoTriggers),nil);
    _ARIS_NOTIF_LISTEN_(@"USER_MOVED",self,@selector(reevaluateAutoTriggers),nil);
  }
  return self;
}

- (void) clearPlayerData
{
  displayQueue = [[NSMutableArray alloc] init];
  displayBlacklist = [[NSMutableArray alloc] init];
}

- (void) inject:(NSObject *)i
{
  [displayQueue removeObject:i];
  [displayQueue insertObject:i atIndex:0];
  _ARIS_NOTIF_SEND_(@"MODEL_DISPLAY_NEW_ENQUEUED", nil, nil);
}

- (void) enqueue:(NSObject *)i
{
  if(![self displayInQueue:i])
    [displayQueue addObject:i];
  _ARIS_NOTIF_SEND_(@"MODEL_DISPLAY_NEW_ENQUEUED", nil, nil);
}

- (void) enqueueTrigger:(Trigger *)t                       { [self enqueue:t]; }
- (void) injectTrigger: (Trigger *)t                       { [self inject:t];  }
- (void) enqueueInstance:(Instance *)i                     { [self enqueue:i]; }
- (void) injectInstance: (Instance *)i                     { [self inject:i];  }
- (void) enqueueObject:(NSObject <InstantiableProtocol>*)o { [self enqueue:o]; }
- (void) injectObject: (NSObject <InstantiableProtocol>*)o { [self inject:o];  }
- (void) enqueueTab:(Tab *)t                               { [self enqueue:t];  }
- (void) injectTab:(Tab *)t                                { [self inject:t];  }

- (NSObject *) dequeue
{
  [self purgeInvalidFromQueue];
  NSObject *o;
  if(displayQueue.count > 0)
  {
    o = displayQueue[0];
    [displayQueue removeObject:o];

    if([o isKindOfClass:[Trigger class]] && ((Trigger *)o).trigger_id != 0) [displayBlacklist addObject:o];
  }
  return o;
}

- (BOOL) displayInQueue:(NSObject *)d
{
  for(long i = 0; i < displayQueue.count; i++)
    if(d == displayQueue[i]) return YES;
  return NO;
}

- (BOOL) displayBlacklisted:(NSObject *)d
{
  for(long i = 0; i < displayBlacklist.count; i++)
    if(d == displayBlacklist[i]) return YES;
  return NO;
}

- (void) reevaluateAutoTriggers
{
  [self purgeInvalidFromQueue];
  //[self tickAndEnqueueAvailableTimers]; //will be called by poller
  [self enqueueNewImmediates];
}

- (void) purgeInvalidFromQueue
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;

  //if trigger in queue no longer available, remove from queue
  for(long i = 0; i < displayQueue.count; i++)
  {
    BOOL valid = NO;
    if(![displayQueue[i] isKindOfClass:[Trigger class]]) continue; //only triggers are blacklisted
    t = displayQueue[i];
    for(long j = 0; j < pt.count; j++)
      if(t.trigger_id == 0 || t.trigger_id == ((Trigger *)pt[j]).trigger_id) valid = YES; //allow artificial triggers to stay in queue
    if(!valid) [displayQueue removeObject:t];
  }

  //if trigger in blacklist no longer available/within range, remove from blacklist
  for(long i = 0; i < displayBlacklist.count; i++)
  {
    BOOL valid = NO;
    if([displayBlacklist[i] isKindOfClass:[Trigger class]]) //only triggers are blacklisted
    {
      t = displayBlacklist[i];
      for(long j = 0; j < pt.count; j++)
      {
        if(
            t == pt[j] &&
            (
             [t.type isEqualToString:@"IMMEDIATE"] ||
             (
              [t.type isEqualToString:@"LOCATION"] &&
              t.trigger_on_enter &&
              (
               t.infinite_distance ||
               [t.location distanceFromLocation:_MODEL_PLAYER_.location] < t.distance
              )
             )
            )
          )
          valid = YES;
      }
    }
    if(!valid) [displayBlacklist removeObject:t];
  }
}

- (void) tickAndEnqueueAvailableTimers
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;
  for(long i = 0; i < pt.count; i++)
  {
    t = pt[i];

    if([t.type isEqualToString:@"TIMER"])
    {
      BOOL inQueue = NO;
      for(long i = 0; i < displayQueue.count; i++)
      {
        if(displayQueue[i] == t) inQueue = YES;
      }
      if(!inQueue && t.time_left > 0)
        t.time_left--;

      if(t.time_left <= 0 && t.seconds > 0)
      {
        t.time_left = t.seconds;
        [self enqueueTrigger:t]; //will auto verify not already in queue
      }
    }
  }
}

- (void) enqueueNewImmediates
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;
  for(long i = 0; i < pt.count; i++)
  {
    t = pt[i];
    if(
        (
         [t.type isEqualToString:@"IMMEDIATE"] ||
         (
          [t.type isEqualToString:@"LOCATION"] &&
          t.trigger_on_enter &&
          (
           t.infinite_distance ||
           [t.location distanceFromLocation:_MODEL_PLAYER_.location] < t.distance
          )
         )
        ) &&
        ![self displayBlacklisted:t]
      )
    {
      [self enqueueTrigger:t]; //will auto verify not already in queue
    }
  }
}

- (void) endPlay
{
  [timerPoller invalidate];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

- (NSString *) serializedName
{
  return @"display_queue";
}

- (void) dealloc
{
  [timerPoller invalidate];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

