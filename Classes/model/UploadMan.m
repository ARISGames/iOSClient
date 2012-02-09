//
//  UploadMan.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadMan.h"
#import "AppServices.h"

@implementation UploadMan
@synthesize uploadContents;
@synthesize context;

-(void)insertUploadContentIntoDictionary:(UploadContent *)uploadContent
{
    if(uploadContent.localFileURL !=nil){
    if(![self.uploadContents objectForKey:[uploadContent note_id]])
    {
        NSMutableDictionary *contentForNote = [[NSMutableDictionary alloc] initWithCapacity:1];
        [contentForNote setObject:uploadContent forKey:uploadContent.localFileURL];
        [uploadContents setObject:contentForNote forKey:[uploadContent note_id]]; 
    }
    else
    {
        [(NSMutableDictionary *)[self.uploadContents objectForKey:[uploadContent note_id]] setObject:uploadContent forKey:uploadContent.localFileURL];
    }
    }
}

-(void)saveUploadContentToCD:(UploadContent *)uploadContent
{
    NSError *error;
    UploadContent *uploadContentCD = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"UploadContent" 
                                      inManagedObjectContext:context];
    
    uploadContentCD.text = uploadContentCD.text;
    uploadContentCD.title = uploadContentCD.title;
    uploadContentCD.type = uploadContentCD.type;
    uploadContentCD.localFileURL = uploadContentCD.localFileURL;
    uploadContentCD.note_id = uploadContentCD.note_id;
    //uploadContentCD.unique_id = uploadContentCD.note_id;
    uploadContentCD.attemptfailed = uploadContentCD.attemptfailed;
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(void)getSavedUploadContents
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *allUploadContents = [[context executeFetchRequest:fetchRequest error:&error] retain];
    for(int i = 0; i < allUploadContents.count; i++)
    {
        UploadContent *uploadContent = (UploadContent *)[allUploadContents objectAtIndex:i];
        [self insertUploadContentIntoDictionary:uploadContent];
    }
    [allUploadContents release];
    [fetchRequest release];
}

- (void) uploadContentForNote:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSString *)aUrl
{
    UploadContent *uploadContent = [[UploadContent alloc] initForNote:noteId withTitle:title withText:text withType:type withFileURL:aUrl hasAttemptedUpload:NO andUniqueIdentifier:-1 andContext:context];
    [self saveUploadContentToCD:uploadContent];
    [self insertUploadContentIntoDictionary:uploadContent];
    [uploadContent release];
    
    
   /* NSString *fileName;
    if([type isEqualToString:kNoteContentTypeAudio])
        fileName = [NSString stringWithFormat:@"%@audio.caf",[NSDate date]];
    else if([type isEqualToString:kNoteContentTypePhoto]){
        fileName = @"image.jpg";
    }
    else if([type isEqualToString:kNoteContentTypeVideo]){
        fileName = @"video.mp4";   
    }
    else fileName = nil;*/
    
    if(text)
    {
    [[AppServices sharedAppServices]addContentToNoteWithText:text type:type mediaId:0 andNoteId:noteId];
    }
    else
    {
        [[AppServices sharedAppServices]addContentToNoteFromFileData:[NSData dataWithContentsOfURL:[NSURL URLWithString:aUrl]] fileName:aUrl name:nil noteId:noteId type:type];
    }
    
}
- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[AppModel sharedAppModel].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppModel sharedAppModel].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
        [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![[AppModel sharedAppModel].managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}
- (id)init
{
    self = [super init];
    if (self) {
        uploadContents = [[NSMutableDictionary alloc] initWithCapacity:5];
        context = [AppModel sharedAppModel].managedObjectContext;
        //[self deleteAllObjects:@"UploadContent"];
        [self getSavedUploadContents];
    }
    return self;
}

- (void)dealloc {
    [context release];
    [uploadContents release];
    [super dealloc];
}

@end