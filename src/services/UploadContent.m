//
//  UploadContent.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadContent.h"
#import "AppModel.h"

@implementation UploadContent

@dynamic title;
@dynamic state;
@dynamic text;
@dynamic type;
@dynamic fileURL;
@dynamic noteId;

/*
 Through we provide a public NSURL interface, the underlying persistant store
 is an NSString.
 */
- (NSString *)getUploadState 
{
    NSString * tmpValue;
    [self willAccessValueForKey:@"state"];
    tmpValue = [self primitiveState];
    [self didAccessValueForKey:@"state"];
    return tmpValue;
}

/*
 Through we provide a public NSURL interface, the underlying persistant store
 is an NSString.
 */
- (NSURL *)fileURL 
{
    NSString * tmpValue;
    [self willAccessValueForKey:@"fileURL"];
    tmpValue = [self primitiveFileURL];
    [self didAccessValueForKey:@"fileURL"];
    return [NSURL URLWithString:tmpValue];
}

- (void)setFileURL:(NSURL *)value 
{
    [self willChangeValueForKey:@"fileURL"];
    [self setPrimitiveFileURL:[value absoluteString]];
    [self didChangeValueForKey:@"fileURL"];
}

/*
 Through we provide a public int interface, the underlying persistant store
 is an NSNumber.
 */
- (int)noteId 
{
    NSNumber * tmpValue;
    [self willAccessValueForKey:@"noteId"];
    tmpValue = [self primitiveNoteId];
    [self didAccessValueForKey:@"noteId"];
    return [tmpValue intValue];
}

- (void)setNoteId:(int)value 
{
    [self willChangeValueForKey:@"noteId"];
    [self setPrimitiveNoteId:[NSNumber numberWithInt:value]];
    [self didChangeValueForKey:@"noteId"];
}

- (Media *) getMedia
{
    NSString *mediaType;
    if([self.type isEqualToString:@"PHOTO"] ||
       [self.type isEqualToString:@"AUDIO"] ||
       [self.type isEqualToString:@"VIDEO"])
        mediaType = self.type;
    else
        mediaType = @"TEXT";

    Media  *media = [[AppModel sharedAppModel].mediaCache mediaForMediaId:[self.fileURL hash]];
    media.url = [self.fileURL absoluteString];
    media.type = mediaType;
    if([self.type isEqualToString:@"PHOTO"])
    {
        NSData *imageData = [NSData dataWithContentsOfURL:self.fileURL];
        media.image = imageData;
    }
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

@end