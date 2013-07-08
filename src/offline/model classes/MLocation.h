//
//  MLocation.h
//  ARIS
//
//  Created by Miodrag Glumac on 12/29/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MMedia, MPlayer;

@interface MLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * typeId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * error;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * locationId;
@property (nonatomic, retain) NSNumber * itemQty;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSNumber * allowsQuickTravel;
@property (nonatomic, retain) NSNumber * force_view;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSNumber * sync;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MMedia *icon;
@property (nonatomic, retain) MGame *game;
@property (nonatomic, retain) MPlayer *player;

@end
