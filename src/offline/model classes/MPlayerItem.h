//
//  MPlayerItem.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/17/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MItem, MPlayer;

@interface MPlayerItem : NSManagedObject

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sync;
@property (nonatomic, retain) MPlayer *player;
@property (nonatomic, retain) MItem *item;
@property (nonatomic, retain) MGame *game;

@end
