//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"
#import "Player.h"

@interface Note : NSObject <GameObjectProtocol>
{
    Player *owner;
    int noteId;
    NSString *name;
    NSString *ndescription;
    NSMutableArray *comments;
    NSMutableArray *contents;
    NSMutableArray *tags;
    int numRatings;
    BOOL showOnMap;
    BOOL showOnList;
    int parentNoteId;
    int parentRating;
    double latitude;
    double longitude;
    NSDate *created;
}

@property (nonatomic, strong) Player *owner;
@property (nonatomic, assign) int noteId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ndescription;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) int numRatings;
@property (nonatomic, assign) BOOL showOnMap;
@property (nonatomic, assign) BOOL showOnList;
@property (nonatomic, assign) int parentNoteId;
@property (nonatomic, assign) int parentRating;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSDate *created;

-(BOOL)isUploading;

@end
