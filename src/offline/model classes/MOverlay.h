//
//  MOverlay.h
//  ARIS
//
//  Created by Miodrag Glumac on 4/17/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MOverlayTile;

@interface MOverlay : NSManagedObject

@property (nonatomic) int16_t overlayId;
@property (nonatomic) int16_t sortOrder;
@property (nonatomic) float alpha;
@property (nonatomic) int16_t numTiles;
@property (nonatomic) int16_t gameOverlayId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * overlayDescription;
@property (nonatomic, retain) NSSet *tiles;
@property (nonatomic, retain) MGame *game;
@end

@interface MOverlay (CoreDataGeneratedAccessors)

- (void)addTilesObject:(MOverlayTile *)value;
- (void)removeTilesObject:(MOverlayTile *)value;
- (void)addTiles:(NSSet *)values;
- (void)removeTiles:(NSSet *)values;

@end
