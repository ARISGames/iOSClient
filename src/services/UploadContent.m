//
//  UploadContent.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadContent.h"
#import "AppModel.h"
#import "MediaCache.h"

@interface UploadContent (CoreDataGeneratedPrimitiveAccessors)

- (NSString *) primitiveState;
- (void) setPrimitiveState:(NSString *)value;

- (NSString *) primitiveFileURL;
- (void) setPrimitiveFileURL:(NSString *)value;

- (NSNumber *) primitiveNoteId;
- (void) setPrimitiveNoteId:(NSNumber *)value;

@end

@implementation UploadContent

@dynamic title;
@dynamic state;
@dynamic text;
@dynamic type;
@dynamic fileURL;
@dynamic noteId;

- (NSString *) getUploadState 
{
    NSString * tmpValue;
    [self willAccessValueForKey:@"state"];
    tmpValue = [self primitiveState];
    [self didAccessValueForKey:@"state"];
    return tmpValue;
}

- (NSURL *) fileURL 
{
    NSString * tmpValue;
    [self willAccessValueForKey:@"fileURL"];
    tmpValue = [self primitiveFileURL];
    [self didAccessValueForKey:@"fileURL"];
    return [NSURL URLWithString:tmpValue];
}

- (void) setFileURL:(NSURL *)value 
{
    [self willChangeValueForKey:@"fileURL"];
    [self setPrimitiveFileURL:[value absoluteString]];
    [self didChangeValueForKey:@"fileURL"];
}

- (int) noteId 
{
    NSNumber * tmpValue;
    [self willAccessValueForKey:@"noteId"];
    tmpValue = [self primitiveNoteId];
    [self didAccessValueForKey:@"noteId"];
    return [tmpValue intValue];
}

- (void) setNoteId:(int)value 
{
    [self willChangeValueForKey:@"noteId"];
    [self setPrimitiveNoteId:[NSNumber numberWithInt:value]];
    [self didChangeValueForKey:@"noteId"];
}

- (Media *) getMedia
{
    Media  *media = [[AppModel sharedAppModel].mediaCache mediaForMediaId:[self.fileURL hash] ofType:self.type]; //gets media with random bs id... why?
    media.url = [self.fileURL absoluteString];
    if([self.type isEqualToString:@"PHOTO"])
        media.image = [NSData dataWithContentsOfURL:self.fileURL];
    NSLog(@"UploadContent: Returning media with ID: %d and type:%@",[media.uid intValue],media.type);
    
    return media;
}

- (NSString *) getTitle
{
    return [self title];
}

- (NSString *) getText
{
    return [self text];
}

- (NSString *) getType
{
    return [self type];
}

- (int) getNoteId
{
    return [self noteId];
}

- (int) getContentId
{
    return -1;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"UploadContent - MediaId:%@ MediaType:%@ UploadStatus:%@ ContentId:%d NoteId:%d",[self getMedia].uid,[self getType],[self getUploadState],[self getContentId],[self getNoteId]];
}

@end
