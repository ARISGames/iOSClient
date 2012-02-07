//
//  UploadContent.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadContent.h"

@implementation UploadContent

@dynamic title;
@dynamic text;
@dynamic fileURL;
@dynamic type;
@dynamic note_id;
@dynamic unique_id;
@dynamic attemptfailed;

- (id) initForNote:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSString *)url hasAttemptedUpload:(BOOL)attemptFailed andUniqueIdentifier:(int)uniqueId
{
    self = [super init];
    self.title = title;
    self.text = text;
    self.type = type;
    self.fileURL = url;
    self.attemptfailed = [NSNumber numberWithBool:attemptFailed];
    self.note_id = [NSNumber numberWithInt:noteId];
    self.unique_id = [NSNumber numberWithInt:uniqueId];
    
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
    Media *media = [[[Media alloc]initWithId:-1 andUrlString:self.fileURL ofType:self.type]autorelease];
    
    return media;
}

- (NSString *) getType
{
    return [self type];
}

- (int) getNoteId
{
    return [[self note_id] intValue];
}

- (int) getContentId
{
    return [[self unique_id] intValue];
}

@end
