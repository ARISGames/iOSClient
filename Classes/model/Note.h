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
    BOOL shared;
    BOOL dropped;
    BOOL showOnMap,showOnList,userLiked;
    int parentNoteId;
    int parentRating;
    nearbyObjectKind	kind;
    int iconMediaId;
    NSString *username;
    NSString *displayname;
    id __unsafe_unretained delegate;
    BOOL hasImage;
    BOOL hasAudio;
    NSString *tagName;
    double latitude;
    double longitude;

}

@property(nonatomic, strong) NSMutableArray *comments;
@property(nonatomic, strong) NSMutableArray *contents;
@property(nonatomic, strong) NSMutableArray *tags;
@property(readwrite,assign)int tagSection;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *displayname;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *tagName;

@property(nonatomic, strong) NSString *text;
@property(readwrite,assign) int noteId;
@property(readwrite, assign) int creatorId;
@property(readwrite, assign) int numRatings;
@property(readwrite, assign) double latitude;
@property(readwrite, assign) double longitude;

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
@property(nonatomic, unsafe_unretained) id delegate;

-(BOOL)isUploading;
@end
