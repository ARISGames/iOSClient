//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Overlay : NSObject {
    
    int overlayId;
    int index;
    NSString *name;
    NSString *description;
    CGFloat alpha;
    int sort_order;
    int num_tiles;
    
    NSMutableArray *tileX;
    NSMutableArray *tileY;
    NSMutableArray *tileZ;
    NSMutableArray *tileFileName;
    NSMutableArray *tileMediaID;
    NSMutableArray *tileImage;
}


@property(readwrite, assign) int overlayId;
@property(readwrite, assign) int index;
@property(readwrite, assign) int sort_order;
@property(readwrite, assign) int num_tiles;

@property(nonatomic) NSString *name;
@property(nonatomic) NSString *description;
@property(nonatomic) CGFloat alpha;
@property(nonatomic) NSMutableArray *tileX;
@property(nonatomic) NSMutableArray *tileY;
@property(nonatomic) NSMutableArray *tileZ;
@property(nonatomic) NSMutableArray *tileFileName;
@property(nonatomic) NSMutableArray *tilePath;
@property(nonatomic) NSMutableArray *tileMediaID;
@property(nonatomic) NSMutableArray *tileImage;


@end
