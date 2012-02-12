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
@dynamic text;
@dynamic type;
@dynamic localFileURL;
@dynamic note_id;
@dynamic attemptfailed;

- (id) initForNote:(NSNumber *)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)aUrl hasAttemptedUpload:(BOOL)attemptFailed andContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"UploadContent" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    if(self){
    self.title = title;
    self.text = text;
    self.type = type;
    self.localFileURL = [aUrl relativePath];
    self.attemptfailed = [NSNumber numberWithBool:attemptFailed];
    self.note_id = noteId;
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
    Media *media;
    //media = [[AppModel sharedAppModel]mediaForMediaId:[self.localFileURL intValue]];
    //if(!media)
    
    //THIS LEAKS AND SHOULD BE FIXED
    NSString *mediaType;
    if([self.type isEqualToString:kNoteContentTypePhoto]){
        mediaType = kMediaTypeImage;
    }
    else if([self.type isEqualToString:kNoteContentTypeAudio]){
        mediaType = kMediaTypeAudio;
    }
    else if([self.type isEqualToString:kNoteContentTypeVideo]){
        mediaType = kMediaTypeVideo;
    }
    else{
        mediaType = @"Text";
    }
    media = [[Media alloc]initWithId:[self.localFileURL hash] andUrl:[NSURL URLWithString: self.localFileURL] ofType:mediaType];
    if([self.type isEqualToString:kNoteContentTypePhoto]){
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.localFileURL]];
        media.image = [UIImage imageWithData:imageData];
            
        
        }
    NSLog(@"UploadContent: Returning media with ID: %d and type:%@",media.uid,media.type);
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

- (NSURL*) getLocalFileURL {
    return [NSURL URLWithString:self.localFileURL];
}

- (int) getContentId
{
    return -1;
}

-(BOOL)isUploading{
    return YES;
}

@end
