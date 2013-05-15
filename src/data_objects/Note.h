//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

enum
{
	NoteContentTypeAudio = 0,
	NoteContentTypeVideo = 0,
	NoteContentTypePhoto = 0,
	NoteContentTypeText  = 0
};
typedef UInt32 NoteContentType;

@interface Note : NSObject <GameObjectProtocol>
{
    int noteId;
    NSString *name;
    NSString *text;
    int creatorId;
    NSString *username;
    NSString *displayname;
    NSMutableArray *comments;
    NSMutableArray *contents;
    NSMutableArray *tags;
    int numRatings;
    BOOL shared;
    BOOL dropped;
    BOOL showOnMap;
    BOOL showOnList;
    BOOL userLiked;
    int parentNoteId;
    int parentRating;
    BOOL hasImage;
    BOOL hasAudio;
    double latitude;
    double longitude;
}

@property (nonatomic, assign) int noteId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) int creatorId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayname;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, assign) int numRatings;
@property (nonatomic, assign) BOOL shared;
@property (nonatomic, assign) BOOL dropped;
@property (nonatomic, assign) BOOL showOnMap;
@property (nonatomic, assign) BOOL showOnList;
@property (nonatomic, assign) BOOL userLiked;
@property (nonatomic, assign) int parentNoteId;
@property (nonatomic, assign) int parentRating;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) BOOL hasAudio;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

-(BOOL)isUploading;

@end
