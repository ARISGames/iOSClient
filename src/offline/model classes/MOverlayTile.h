//
//  MOverlayTile.h
//  ARIS
//
//  Created by Miodrag Glumac on 4/17/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MMedia, MOverlay;

@interface MOverlayTile : NSManagedObject

@property (nonatomic) int16_t zoom;
@property (nonatomic) int32_t x;
@property (nonatomic) int32_t xMax;
@property (nonatomic) int32_t y;
@property (nonatomic) int32_t yMax;
@property (nonatomic, retain) MOverlay *overlay;
@property (nonatomic, retain) MMedia *media;

@end
