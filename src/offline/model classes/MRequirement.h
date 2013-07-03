//
//  MRequirement.h
//  ARIS
//
//  Created by Miodrag Glumac on 2/20/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame;

@interface MRequirement : NSManagedObject

@property (nonatomic, retain) NSNumber * contentId;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSString * booleanOperator;
@property (nonatomic, retain) NSString * requirementDetail3;
@property (nonatomic, retain) NSString * requirementDetail1;
@property (nonatomic, retain) NSString * requirement;
@property (nonatomic, retain) NSString * requirementDetail2;
@property (nonatomic, retain) NSNumber * requirementId;
@property (nonatomic, retain) NSString * notOperator;
@property (nonatomic, retain) NSString * groupOperator;
@property (nonatomic, retain) MGame *game;

@end
