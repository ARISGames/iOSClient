//
//  MGame.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/24/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MComment, MItem, MLocation, MMap, MMedia, MNode, MNpc, MPlayerLog, MQRCode, MQuest, MRequirement, MTab;

@interface MGame : NSManagedObject

@property (nonatomic, retain) NSNumber * calculatedScore;
@property (nonatomic, retain) NSNumber * gameCompleteNodeId;
@property (nonatomic, retain) NSString * gameDescription;
@property (nonatomic, retain) NSNumber * allowPlayerCreatedLocations;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * gameId;
@property (nonatomic, retain) NSNumber * numPlayers;
@property (nonatomic, retain) NSNumber * isLocational;
@property (nonatomic, retain) NSNumber * inventoryWeightCap;
@property (nonatomic, retain) NSNumber * deletePlayerLocationsOnReset;
@property (nonatomic, retain) NSNumber * completedQuests;
@property (nonatomic, retain) NSNumber * totalQuests;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSSet *requirements;
@property (nonatomic, retain) NSSet *maps;
@property (nonatomic, retain) NSSet *quests;
@property (nonatomic, retain) NSSet *npcs;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) MMedia *icon;
@property (nonatomic, retain) NSSet *tabs;
@property (nonatomic, retain) MMedia *media;
@property (nonatomic, retain) NSSet *logs;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSSet *nodes;
@property (nonatomic, retain) MNode *gameCompleteNode;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *medias;
@property (nonatomic, retain) MMedia *gameIcon;
@property (nonatomic, retain) MNode *onLaunchNode;
@property (nonatomic, retain) NSSet *qrCodes;
@property (nonatomic, retain) NSSet *overlays;
@property (nonatomic, retain) NSNumber *offline;
@property (nonatomic, retain) NSNumber *hasBeenPlayed;
@end

@interface MGame (CoreDataGeneratedAccessors)

- (void)addRequirementsObject:(MRequirement *)value;
- (void)removeRequirementsObject:(MRequirement *)value;
- (void)addRequirements:(NSSet *)values;
- (void)removeRequirements:(NSSet *)values;
- (void)addMapsObject:(MMap *)value;
- (void)removeMapsObject:(MMap *)value;
- (void)addMaps:(NSSet *)values;
- (void)removeMaps:(NSSet *)values;
- (void)addQuestsObject:(MQuest *)value;
- (void)removeQuestsObject:(MQuest *)value;
- (void)addQuests:(NSSet *)values;
- (void)removeQuests:(NSSet *)values;
- (void)addNpcsObject:(MNpc *)value;
- (void)removeNpcsObject:(MNpc *)value;
- (void)addNpcs:(NSSet *)values;
- (void)removeNpcs:(NSSet *)values;
- (void)addItemsObject:(MItem *)value;
- (void)removeItemsObject:(MItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;
- (void)addTabsObject:(MTab *)value;
- (void)removeTabsObject:(MTab *)value;
- (void)addTabs:(NSSet *)values;
- (void)removeTabs:(NSSet *)values;
- (void)addLogsObject:(MPlayerLog *)value;
- (void)removeLogsObject:(MPlayerLog *)value;
- (void)addLogs:(NSSet *)values;
- (void)removeLogs:(NSSet *)values;
- (void)addLocationsObject:(MLocation *)value;
- (void)removeLocationsObject:(MLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;
- (void)addNodesObject:(MNode *)value;
- (void)removeNodesObject:(MNode *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;
- (void)addCommentsObject:(MComment *)value;
- (void)removeCommentsObject:(MComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
- (void)addMediasObject:(MMedia *)value;
- (void)removeMediasObject:(MMedia *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;
- (void)addQrCodesObject:(MQRCode *)value;
- (void)removeQrCodesObject:(MQRCode *)value;
- (void)addQrCodes:(NSSet *)values;
- (void)removeQrCodes:(NSSet *)values;
- (void)addOverlaysObject:(MQRCode *)value;
- (void)removeOverlaysObject:(MQRCode *)value;
- (void)addOverlays:(NSSet *)values;
- (void)removeOverlays:(NSSet *)values;
@end
