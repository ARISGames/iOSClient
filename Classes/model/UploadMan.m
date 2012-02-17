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
    [fetchRequest release];
    
    
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
    [fetchRequest release];
    
    
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
    [title retain];
    [text retain];
    [type retain];
    [fileURL retain];
    [state retain];
    
    [self deleteUploadContentFromCDFromNoteId:noteId andFileURL:fileURL]; //Prevent Duplicates
    NSLog(@"UploadMan:saveUploadContentToCD"); 
    NSError *error;
    UploadContent *uploadContentCD = [[NSEntityDescription
                                      insertNewObjectForEntityForName:@"UploadContent" 
                                      inManagedObjectContext:context] retain];
    
    uploadContentCD.text = text;
    uploadContentCD.title = title;
    uploadContentCD.type = type;
    uploadContentCD.noteId = noteId;
    uploadContentCD.fileURL = fileURL;
    uploadContentCD.state = state;
    
    [title release];
    [text release];
    [type release];
    [fileURL release];
    [state release];
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return [uploadContentCD autorelease];
}

-(void)getSavedUploadContents
{
    NSLog(@"UploadMan:getSavedUploadContents");
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *allUploadContents = [[context executeFetchRequest:fetchRequest error:&error] retain];
    for(int i = 0; i < allUploadContents.count; i++)
    {
        UploadContent *uploadContent = (UploadContent *)[allUploadContents objectAtIndex:i];
        uploadContent.state = @"uploadStateFAILED";
        [self insertUploadContentIntoDictionary:uploadContent];
    }
    [allUploadContents release];
    [fetchRequest release];
}

#pragma mark Header Implementations

- (void) uploadContentForNoteId:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)aUrl
{    
    UploadContent * uc = [[self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateQUEUED"] retain];
    [self insertUploadContentIntoDictionary:uc];
    [uc release];
    
    if(text)
    {
        [[AppServices sharedAppServices]addContentToNoteWithText:text type:type mediaId:0 andNoteId:noteId andFileURL:aUrl];
    }
    else
    {
        if(self.currentUploadCount < self.maxUploadCount)
        {
            [[AppServices sharedAppServices]uploadContentToNoteWithFileURL:aUrl name:nil noteId:noteId type:type]; 
            UploadContent * uc = [[self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateUPLOADING"] retain];
            [self insertUploadContentIntoDictionary:uc];
            [uc release];
            self.currentUploadCount++;
        }
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
    NSArray *keyArray =  [self.uploadContents allKeys];
    for (int i=0; i < [keyArray count]; i++) {
        NSArray *tmp = [[self.uploadContents objectForKey:[ keyArray objectAtIndex:i]] allKeys];
        for (int j=0; j < [tmp count]; j++) {
            UploadContent * uc = [[self.uploadContents objectForKey:[ keyArray objectAtIndex:i]] retain];
            uc.state = @"uploadStateFAILED";
            UploadContent * newuc = [[self saveUploadContentToCDWithTitle:[uc getTitle] andText:[uc getText] andType:[uc getType] andNoteId:[uc getNoteId] andFileURL:uc.fileURL inState:[uc getUploadState]] retain];
            [self insertUploadContentIntoDictionary:newuc];
            [uc release];
            [newuc release];
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
        self.uploadContents = [[NSMutableDictionary alloc] initWithCapacity:5];
        self.context = [AppModel sharedAppModel].managedObjectContext;
        //[self deleteAllObjects:@"UploadContent"]; //USE TO DELETE ALL CORE DATA STUFF
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