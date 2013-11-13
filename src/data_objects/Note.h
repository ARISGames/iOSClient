//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"
@class Player;
@class Location;
@class Tag;
@class NoteContent;

@interface Note : NSObject <GameObjectProtocol>
{
    int noteId; 
    Player *owner;
    NSString *name;
    NSString *ndescription;
    NSDate *created; 
    Location *location; 
    NSMutableArray *tags;
    NSMutableArray *contents;
    NSMutableArray *comments; 
    BOOL publicToList;
    BOOL publicToMap; 
}

@property (nonatomic, assign) int noteId;
@property (nonatomic, strong) Player *owner;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *ndescription;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) BOOL publicToList;
@property (nonatomic, assign) BOOL publicToMap;

-(BOOL) isUploading;

@end
