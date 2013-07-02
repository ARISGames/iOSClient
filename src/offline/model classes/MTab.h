//
//  MTab.h
//  ARIS
//
//  Created by Miodrag Glumac on 8/25/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame;

@interface MTab : NSManagedObject

@property (nonatomic, retain) NSString * tab;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) MGame *game;

@end
