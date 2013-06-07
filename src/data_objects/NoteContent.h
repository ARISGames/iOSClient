//
//  NoteContent.h
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModel.h"
#import "NoteContentProtocol.h"
#import "Note.h"

@interface NoteContent : NSObject <NoteContentProtocol>
{
    int contentId;
    int mediaId;
    int noteId;
    int sortIndex;
    NSString *text;
    NSString *title;
    NSString *type;
}

@property (nonatomic, assign) int contentId;
@property (nonatomic, assign) int mediaId;
@property (nonatomic, assign) int noteId;
@property (nonatomic, assign) int sortIndex;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;

- (NoteContent *) initWithDictionary:(NSDictionary *)dict;

@end
