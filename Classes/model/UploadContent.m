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
@dynamic localFileURL;
@dynamic type;
@dynamic note_id;
@dynamic attemptfailed;

- (id) initForNote:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSString *)aUrl hasAttemptedUpload:(BOOL)attemptFailed andUniqueIdentifier:(int)uniqueId andContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"UploadContent" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    if(self){
    self.title = title;
    self.text = text;
    self.type = type;
    self.localFileURL = aUrl;
    self.attemptfailed = [NSNumber numberWithBool:attemptFailed];
    self.note_id = [NSNumber numberWithInt:noteId];
    //self.unique_id = [NSNumber numberWithInt:uniqueId];
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
    media = [[Media alloc]initWithId:[self.localFileURL hash] andUrlString:self.localFileURL ofType:self.type];
    if([self.type isEqualToString:kNoteContentTypePhoto])
        media.image = [UIImage imageWithContentsOfFile:self.localFileURL];
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

- (int) getContentId
{
    return -1;
}

-(BOOL)isUploading{
    return YES;
}

@end
