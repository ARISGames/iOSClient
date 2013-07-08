//
//  MPlayerStateChange.h
//  ARIS
//
//  Created by Miodrag Glumac on 2/21/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame;

@interface MPlayerStateChange : NSManagedObject

@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSNumber * eventDetail;
@property (nonatomic, retain) NSNumber * actionAmount;
@property (nonatomic, retain) NSNumber * actionDetail;
@property (nonatomic, retain) NSNumber * playerStateChangeId;
@property (nonatomic, retain) MGame *game;

@end
