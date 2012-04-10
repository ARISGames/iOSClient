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
@synthesize currentUploadCount;
@synthesize maxUploadCount;

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[AppModel sharedAppModel].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppModel sharedAppModel].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![[AppModel sharedAppModel].managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

- (void) deleteUploadContentFromDictionaryFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
    [(NSMutableDictionary *)[uploadContents objectForKey:[NSNumber numberWithInt: noteId]] removeObjectForKey:fileURL];
    if([[(NSMutableDictionary *)[uploadContents objectForKey:[NSNumber numberWithInt: noteId]] allValues] count] == 0)
    {
        [uploadContents removeObjectForKey:[NSNumber numberWithInt: noteId]];
    }
}

- (void) deleteUploadContentFromCDFromNoteId:(int)noteId andFileURL:(NSURL *)afileURL
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" inManagedObjectContext:[AppModel sharedAppModel].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppModel sharedAppModel].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        NSURL *objectURL = [(UploadContent *)managedObject fileURL];
        if([[objectURL absoluteString] isEqualToString:[afileURL absoluteString]])
        {
            [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
            NSLog(@"%@ object deleted",@"UploadContent");
        }
    }
    if (![[AppModel sharedAppModel].managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",@"UploadContent",error);
    }

}

-(void)insertUploadContentIntoDictionary:(UploadContent *)uploadContent
{
    if(!uploadContent.fileURL)
    {    NSLog(@"UploadMan: insertUploadContentIntoDictionary returning early becasue fileURL was nil");
        return;
    }
    if(![self.uploadContents objectForKey:[NSNumber numberWithInt:[uploadContent noteId]]])
    {
        NSMutableDictionary *contentForNote = [[NSMutableDictionary alloc] initWithCapacity:1];
        [contentForNote setObject:uploadContent forKey:uploadContent.fileURL];
        [uploadContents setObject:contentForNote forKey:[NSNumber numberWithInt:[uploadContent noteId]]]; 
        NSLog(@"UploadMan: adding contentForKey:%@ to noteForKey:%d",uploadContent.fileURL,uploadContent.noteId);
    }
    else
    {
        [(NSMutableDictionary *)[self.uploadContents objectForKey:[NSNumber numberWithInt:[uploadContent noteId]]] setObject:uploadContent forKey:uploadContent.fileURL];
        NSLog(@"UploadMan: adding contentForKey:%@ to noteForKey:%d",uploadContent.fileURL,uploadContent.noteId);
        
    }
    
}


-(UploadContent *)saveUploadContentToCDWithTitle:(NSString *)title andText:(NSString *)text andType:(NSString *)type andNoteId:(int)noteId andFileURL:(NSURL *)fileURL inState:(NSString *)state
{
    //Retains input, as they may be pointers from an object that will get deleted
    
    [self deleteUploadContentFromCDFromNoteId:noteId andFileURL:fileURL]; //Prevent Duplicates
    NSLog(@"UploadMan:saveUploadContentToCD"); 
    NSError *error;
    UploadContent *uploadContentCD = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"UploadContent" 
                                      inManagedObjectContext:context];
    
    uploadContentCD.text = text;
    uploadContentCD.title = title;
    uploadContentCD.type = type;
    uploadContentCD.noteId = noteId;
    uploadContentCD.fileURL = fileURL;
    uploadContentCD.state = state;
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return uploadContentCD;
}

-(void)getSavedUploadContents
{
    NSLog(@"UploadMan:getSavedUploadContents");
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *allUploadContents = [context executeFetchRequest:fetchRequest error:&error];
    for(int i = 0; i < allUploadContents.count; i++)
    {
        UploadContent *uploadContent = (UploadContent *)[allUploadContents objectAtIndex:i];
        uploadContent.state = @"uploadStateFAILED";
        [self insertUploadContentIntoDictionary:uploadContent];
    }
}

#pragma mark Header Implementations

- (void) uploadContentForNoteId:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)aUrl
{    
    UploadContent * uc = [self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateQUEUED"];
    [self insertUploadContentIntoDictionary:uc];
    
    if(text)
    {
        [[AppServices sharedAppServices]addContentToNoteWithText:text type:type mediaId:0 andNoteId:noteId andFileURL:aUrl];
    }
    else
    {            [[AppServices sharedAppServices]uploadContentToNoteWithFileURL:aUrl name:nil noteId:noteId type:type]; 

           }
    if(self.currentUploadCount < self.maxUploadCount)
    {
        UploadContent * uc = [self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateUPLOADING"];
        [self insertUploadContentIntoDictionary:uc];
        self.currentUploadCount++;
    }

}

- (void) contentFinishedUploading
{
    self.currentUploadCount--;
    NSArray *noteIdKeyArray =  [self.uploadContents allKeys];
    for (int i=0; i < [noteIdKeyArray count]; i++) {
        NSArray *contentIdKeyArray = [[self.uploadContents objectForKey:[noteIdKeyArray objectAtIndex:i]] allKeys];
        for (int j=0; j < [contentIdKeyArray count]; j++) {
            UploadContent * uc = [[self.uploadContents objectForKey:[ noteIdKeyArray objectAtIndex:i]] objectForKey:[ contentIdKeyArray objectAtIndex:j]];
            if([[uc getUploadState] isEqualToString:@"uploadStateQUEUED"])
            {
                [self uploadContentForNoteId:uc.noteId withTitle:uc.title withText: uc.text withType:uc.type withFileURL:uc.fileURL];
                return;
            }
        }
    }
}

- (void) contentFailedUploading
{
    NSArray *noteIdKeyArray =  [self.uploadContents allKeys];
    for (int i=0; i < [noteIdKeyArray count]; i++) {
        NSArray *contentIdKeyArray = [[self.uploadContents objectForKey:[noteIdKeyArray objectAtIndex:i]] allKeys];
        for (int j=0; j < [contentIdKeyArray count]; j++) {
            UploadContent * uc = [[self.uploadContents objectForKey:[ noteIdKeyArray objectAtIndex:i]] objectForKey:[ contentIdKeyArray objectAtIndex:j]];
            uc.state = @"uploadStateFAILED";
            UploadContent * newuc = [self saveUploadContentToCDWithTitle:[uc getTitle] andText:[uc getText] andType:[uc getType] andNoteId:[uc getNoteId] andFileURL:uc.fileURL inState:[uc getUploadState]];
            [self insertUploadContentIntoDictionary:newuc];
        }
    }
    self.currentUploadCount = 0; //Resume Possibility of new uploads
}

- (void) deleteContentFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
    [self deleteUploadContentFromDictionaryFromNoteId:noteId andFileURL:fileURL];
    [self deleteUploadContentFromCDFromNoteId:noteId andFileURL:fileURL];
    
    // For error information
    NSError *error;
    
    // Create file manager
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr removeItemAtPath:[fileURL relativePath] error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    else
        NSLog(@"File Successfully Deleted");
}

- (id)init
{
    self = [super init];
    if (self) {
        currentUploadCount = 0;
        maxUploadCount = 1;
        uploadContents = [[NSMutableDictionary alloc] initWithCapacity:5];
        self.context = [AppModel sharedAppModel].managedObjectContext;
        //[self deleteAllObjects:@"UploadContent"]; //USE TO DELETE ALL CORE DATA STUFF
        [self getSavedUploadContents];
    }
    return self;
}


@end