//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"


@interface Note : NSObject <NearbyObjectProtocol>{
    NSArray *mediaArray;
    int noteId;
    int creatorId;
    NSString *title;
    NSString *text;
    int numRatings;
    float averageRating;
    BOOL shared;
    int parentNoteId;
    int parentRating;
    nearbyObjectKind	kind;
    int iconMediaId;

}

@property(nonatomic,retain) NSArray *mediaArray;
@property(nonatomic,retain) NSString *title;
@property(nonatomic, retain) NSString *text;
@property(readwrite,assign) int noteId;
@property(readwrite, assign) int creatorId;
@property(readwrite, assign) int numRatings;
@property(readwrite, assign) float averageRating;
@property(readwrite, assign) BOOL shared;
@property(readwrite, assign) int parentNoteId;
@property(readwrite, assign) int parentRating;
@property(readwrite, assign) nearbyObjectKind kind;
@property(readwrite, assign) int iconMediaId;

@end
