//
//  MItem.h
//  ARIS
//
//  Created by Miodrag Glumac on 11/4/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MMedia, MPlayer;

@interface MItem : NSManagedObject

@property (nonatomic, retain) NSNumber * maxQtyInInventory;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSDate * originTimestamp;
@property (nonatomic, retain) NSNumber * destroyable;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * kind;
@property (nonatomic, retain) NSNumber * originLatitude;
@property (nonatomic, retain) NSNumber * dropable;
@property (nonatomic, retain) NSNumber * originLongitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) MMedia *icon;
@property (nonatomic, retain) MPlayer *creator;
@property (nonatomic, retain) MMedia *media;
@property (nonatomic, retain) MGame *game;

@end
