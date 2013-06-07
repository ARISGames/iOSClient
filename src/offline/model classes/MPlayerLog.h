//
//  MPlayerLog.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/14/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MPlayer;

@interface MPlayerLog : NSManagedObject

@property (nonatomic, retain) NSString * eventDetail2;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * sync;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSNumber * playerLogId;
@property (nonatomic, retain) NSNumber * playerId;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * eventDetail1;
@property (nonatomic, retain) MPlayer *player;
@property (nonatomic, retain) MGame *game;

@end
