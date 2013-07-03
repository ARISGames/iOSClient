//
//  MPlayer.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/17/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MLocation, MPlayerItem, MPlayerLog, MQuest;

@interface MPlayer : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * playerId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *quests;
@property (nonatomic, retain) NSSet *logs;
@property (nonatomic, retain) MGame *lastGame;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSSet *playerItems;
@end

@interface MPlayer (CoreDataGeneratedAccessors)

- (void)addQuestsObject:(MQuest *)value;
- (void)removeQuestsObject:(MQuest *)value;
- (void)addQuests:(NSSet *)values;
- (void)removeQuests:(NSSet *)values;
- (void)addLogsObject:(MPlayerLog *)value;
- (void)removeLogsObject:(MPlayerLog *)value;
- (void)addLogs:(NSSet *)values;
- (void)removeLogs:(NSSet *)values;
- (void)addLocationsObject:(MLocation *)value;
- (void)removeLocationsObject:(MLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;
- (void)addPlayerItemsObject:(MPlayerItem *)value;
- (void)removePlayerItemsObject:(MPlayerItem *)value;
- (void)addPlayerItems:(NSSet *)values;
- (void)removePlayerItems:(NSSet *)values;
@end
