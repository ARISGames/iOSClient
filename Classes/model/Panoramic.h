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
    int mediaId;
    int alignMediaId;
    int panoramicId;
    nearbyObjectKind kind;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *description;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int mediaId;
@property(readwrite, assign) int alignMediaId;
@property(readwrite, assign) int panoramicId;
@property(readwrite, assign) nearbyObjectKind kind;

@end
