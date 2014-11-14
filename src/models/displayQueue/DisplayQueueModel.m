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
}
@end

@implementation DisplayQueueModel

- (id) init
{
  if(self = [super init])
  {
    [self clear];
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_NEW_AVAILABLE",self,@selector(enqueueNewImmediates),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_TRIGGERS_LESS_AVAILABLE",self,@selector(purgeInvalidFromQueue),nil);
  }
  return self;
}

- (void) clear
{
    displayQueue = [[NSMutableArray alloc] init];
    displayBlacklist = [[NSMutableArray alloc] init];
}

- (void) inject:(id)i
{
  [displayQueue removeObject:i];
  [displayQueue insertObject:i atIndex:0];
  _ARIS_NOTIF_SEND_(@"MODEL_DISPLAY_NEW_ENQUEUED", nil, nil);
}

- (void) enqueue:(id)i
{
  if(![self displayInQueue:i])
    [displayQueue addObject:i];
  _ARIS_NOTIF_SEND_(@"MODEL_DISPLAY_NEW_ENQUEUED", nil, nil);
}

- (void) enqueueTrigger:(Trigger *)t               { [self enqueue:t]; }
- (void) injectTrigger: (Trigger *)t               { [self inject:t];  }
- (void) enqueueInstance:(Instance *)i             { [self enqueue:i]; }
- (void) injectInstance: (Instance *)i             { [self inject:i];  }
- (void) enqueueObject:(id<InstantiableProtocol>)o { [self enqueue:o]; }
- (void) injectObject: (id<InstantiableProtocol>)o { [self inject:o];  }
- (void) enqueueTab:(Tab *)t                       { [self enqueue:t];  }
- (void) injectTab:(Tab *)t                        { [self inject:t];  }

- (id) dequeue
{
  [self purgeInvalidFromQueue];
  Trigger *t;
  if(displayQueue.count > 0)
  {
    t = displayQueue[0];
    [displayQueue removeObject:t];
    if(t.trigger_id != 0) [displayBlacklist addObject:t]; //don't bother blacklisting artificial triggers
  }
  return t;
}

- (BOOL) displayInQueue:(id)d
{
  for(int i = 0; i < displayQueue.count; i++)
    if(d == displayQueue[i]) return YES;
  return NO;
}

- (BOOL) displayBlacklisted:(id)d
{
  for(int i = 0; i < displayBlacklist.count; i++)
    if(d == displayBlacklist[i]) return YES;
  return NO;
}

- (void) purgeInvalidFromQueue
{
  NSArray *pt = _MODEL_TRIGGERS_.playerTriggers;
  Trigger *t;

  //if trigger in queue no longer available, remove from queue
  for(int i = 0; i < displayQueue.count; i++)
  {
    BOOL valid = NO;
    t = displayQueue[i];
    for(int j = 0; j < pt.count; j++)
      if(t.trigger_id == 0 || t.trigger_id == ((Trigger *)pt[j]).trigger_id) valid = YES; //allow artificial triggers to stay in queue
    if(!valid) [displayQueue removeObject:t];
  }
    
  //if trigger in blacklist no longer available/within range, remove from blacklist
  for(int i = 0; i < displayBlacklist.count; i++)
  {
    BOOL valid = NO;
    t = displayBlacklist[i];
    for(int j = 0; j < pt.count; j++)
      if(t == pt[j] && ([t.type isEqualToString:@"IMMEDIATE"] || ([t.type isEqualToString:@"LOCATION"] && t.trigger_on_enter && [t.location distanceFromLocation:_MODEL_PLAYER_.location] < t.distance))) valid = YES;
    if(!valid) [displayBlacklist removeObject:t];
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
       && ![self displayBlacklisted:t])
      [self enqueueTrigger:t]; //will auto verify not already in queue
  }
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);   
}

@end
