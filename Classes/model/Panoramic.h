//
//  Panoramic.h
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"

@interface Panoramic : NSObject<NearbyObjectProtocol> {
    NSString *name;
    NSString *description;
    int iconMediaId;
    NSArray *media;
    int alignMediaId;
    int panoramicId;
    nearbyObjectKind kind;
    NSArray *textureArray;
}

@property(nonatomic) NSString *name;
@property(nonatomic) NSString *description;
@property(nonatomic) NSArray *textureArray;
@property(readwrite, assign) int iconMediaId;
@property(nonatomic) NSArray *media;
@property(readwrite, assign) int alignMediaId;
@property(readwrite, assign) int panoramicId;
@property(readwrite, assign) nearbyObjectKind kind;

@end
