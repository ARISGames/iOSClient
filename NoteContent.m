//
//  NoteContent.m
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteContent.h"


@implementation NoteContent
@synthesize contentId,mediaId,noteId,sortIndex,type,text,title;

- (NoteContent *) init {
    if (self = [super init]) {
    }
    return self;	
}

- (NSString *) getTitle
{
    return [self title];
}

- (NSString *) getText
{
    return [self text];
}

- (Media *) getMedia
{
    return [[AppModel sharedAppModel] mediaForMediaId:[self mediaId]];
}

- (NSString *) getType
{
    return [self type];
}

- (NSString *) getUploadState
{
    return @"uploadStateDONE";
}

- (int) getNoteId
{
    return [self noteId];
}

- (int) getContentId
{
    return [self contentId];
}

- (id) managedObjectContext
{
    return @"I'm Not nil!";
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
