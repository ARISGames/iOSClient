//
//  MMedia.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/14/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame;

@interface MMedia : NSManagedObject

@property (nonatomic, retain) NSString * gameId;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * mediaId;
@property (nonatomic, retain) NSNumber * defaultMedia;
@property (nonatomic, retain) NSNumber * icon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) MGame *game;

@end
