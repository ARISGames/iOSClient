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
@synthesize media;

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
    return [NSURL URLWithString: tmpValue];
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


- (id) initForNoteId:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)aUrl inState:(NSString *)state andContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"UploadContent" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    if(self){
        self.title = title;
        self.text = text;
        self.type = type;
        self.fileURL = aUrl;
        self.state = state;
        self.noteId = noteId;
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
    //media = [[AppModel sharedAppModel]mediaForMediaId:[self.localFileURL intValue]];
    //if(!media)
    
    //THIS LEAKS AND SHOULD BE FIXED
    if(self.media == nil){
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
    //Just to get ARC working
    //media = [[Media alloc]initWithId:[self.fileURL hash] andUrl:self.fileURL ofType:mediaType];
    if([self.type isEqualToString:kNoteContentTypePhoto]){
        
        NSData *imageData = [NSData dataWithContentsOfURL:self.fileURL];
        media.image = imageData;
        
        }
    NSLog(@"UploadContent: Returning media with ID: %d and type:%@",media.uid,media.type);
    }
    return media;
}

- (NSString *) getType
{
    return [self type];
}

- (NSString *) getUploadState
{
    return [self state];
}

//THIS IS REALLY WEIRD AND SHOULD JUST BE USING THE DYNAMIC GETTER
- (int) getNoteId {
    return self.noteId;
}

- (int) getContentId
{
    return -1;
}


@end
