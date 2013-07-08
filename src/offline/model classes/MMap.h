//
//  MMap.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/18/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MMedia;

@interface MMap : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * zoom;
@property (nonatomic, retain) MGame *game;
@property (nonatomic, retain) MMedia *media;

@end
