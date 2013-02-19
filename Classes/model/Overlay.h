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

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *description;
@property(nonatomic) CGFloat alpha;
@property(nonatomic, strong) NSMutableArray *tileX;
@property(nonatomic, strong) NSMutableArray *tileY;
@property(nonatomic, strong) NSMutableArray *tileZ;
@property(nonatomic, strong) NSMutableArray *tileFileName;
@property(nonatomic, strong) NSMutableArray *tilePath;
@property(nonatomic, strong) NSMutableArray *tileMediaID;
@property(nonatomic, strong) NSMutableArray *tileImage;


@end
