//
//  MComment.h
//  ARIS
//
//  Created by Miodrag Glumac on 9/29/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MPlayer;

@interface MComment : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) MPlayer *player;
@property (nonatomic, retain) MGame *game;

@end
