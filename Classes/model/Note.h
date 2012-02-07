//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"
extern NSString *const kNoteContentTypeAudio;
extern NSString *const kNoteContentTypeVideo;
extern NSString *const kNoteContentTypePhoto;
extern NSString *const kNoteContentTypeText;

@interface Note : NSObject <NearbyObjectProtocol>{
    NSMutableArray *comments;
    NSMutableArray *contents;
    NSMutableArray *tags;
    int noteId;
    int creatorId;
    NSString *title;
    NSString *text;
    int numRatings;
    float averageRating;
    BOOL shared;
    BOOL dropped;
    BOOL showOnMap,showOnList,userLiked;
    int parentNoteId;
    int parentRating;
    nearbyObjectKind	kind;
    int iconMediaId;
    NSString *username;
    id delegate;
    BOOL hasImage;
    BOOL hasAudio;
    NSString *tagName;
}

@property(nonatomic,retain) NSMutableArray *comments;
@property(nonatomic,retain) NSMutableArray *contents;
@property(nonatomic,retain) NSMutableArray *tags;
@property(readwrite,assign)int tagSection;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *tagName;

@property(nonatomic, retain) NSString *text;
@property(readwrite,assign) int noteId;
@property(readwrite, assign) int creatorId;
@property(readwrite, assign) int numRatings;
@property(readwrite, assign) float averageRating;
@property(readwrite, assign) BOOL shared;
@property(readwrite, assign) BOOL dropped;
@property(readwrite, assign) BOOL showOnMap;
@property(readwrite, assign) BOOL showOnList;
@property(readwrite, assign) BOOL userLiked;
@property(readwrite, assign) BOOL hasImage;
@property(readwrite, assign) BOOL hasAudio;
@property(readwrite, assign) int parentNoteId;
@property(readwrite, assign) int parentRating;
@property(readwrite, assign) nearbyObjectKind kind;
@property(nonatomic, retain) id delegate;

-(BOOL)isUploading;
@end
