//
//  MQuest.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/14/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MMedia, MPlayer;

@interface MQuest : NSManagedObject

@property (nonatomic, retain) NSString * textWhenComplete;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) NSNumber * questId;
@property (nonatomic, retain) NSString * questDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MGame *game;
@property (nonatomic, retain) MMedia *icon;
@property (nonatomic, retain) MPlayer *player;

@end
