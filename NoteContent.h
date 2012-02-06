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

@interface NoteContent : NSObject <NoteContentProtocol> {
    int contentId;
    int mediaId;
    int noteId;
    int sortIndex;
    NSString *text;
    NSString *title;
    NSString *type;
}

@property(readwrite,assign)int contentId;
@property(readwrite,assign)int mediaId;
@property(readwrite,assign)int noteId;
@property(readwrite,assign)int sortIndex;
@property(nonatomic, retain)NSString *text;
@property(nonatomic, retain)NSString *title;
@property(nonatomic, retain)NSString *type;

@end
