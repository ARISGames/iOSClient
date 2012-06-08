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
@synthesize uploadContentsForNotes;
@synthesize context;
@synthesize currentUploadCount;
@synthesize maxUploadCount;

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSLog(@"UploadMan: Deleting all CoreData Objects");
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
    //PHIL APPROVED
    NSLog(@"UploadMan: Deleting Upload Content from local dictionary");
    [(NSMutableDictionary *)[uploadContentsForNotes objectForKey:[NSNumber numberWithInt: noteId]] removeObjectForKey:fileURL];
    if([[(NSMutableDictionary *)[uploadContentsForNotes objectForKey:[NSNumber numberWithInt: noteId]] allValues] count] == 0)
    {
        [uploadContentsForNotes removeObjectForKey:[NSNumber numberWithInt: noteId]];
    }
}

- (void) deleteUploadContentFromCDFromNoteId:(int)noteId andFileURL:(NSURL *)theFileURL
{
    //PHIL APPROVED
    NSLog(@"UploadMan: Deleting Upload Content from CoreData");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *uploadContents = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (UploadContent *uploadContent in uploadContents) {
        NSURL *fileURL = [uploadContent fileURL];
        if([[fileURL absoluteString] isEqualToString:[theFileURL absoluteString]])
        {
            [self.context deleteObject:uploadContent];
            NSLog(@"UploadContent object deleted");
        }
    }
    if (![self.context save:&error]) {
        NSLog(@"Error deleting UploadContent - error:%@",error);
    }
}

-(void)insertUploadContentIntoDictionary:(UploadContent *)uploadContent
{
    //PHIL APPROVED
    NSLog(@"UploadMan: Inserting Upload Content into local dictionary");
    if(!uploadContent.fileURL)
    {    
        NSLog(@"UploadMan: insertUploadContentIntoDictionary returning early becasue fileURL was nil");
        return;
    }
    if(![self.uploadContentsForNotes objectForKey:[NSNumber numberWithInt:[uploadContent noteId]]])
    {
        NSMutableDictionary *contentsForNote = [[NSMutableDictionary alloc] initWithCapacity:1];
        [contentsForNote setObject:uploadContent forKey:uploadContent.fileURL];
        [uploadContentsForNotes setObject:contentsForNote forKey:[NSNumber numberWithInt:[uploadContent noteId]]]; 
    }
    else
    {
        [(NSMutableDictionary *)[self.uploadContentsForNotes objectForKey:[NSNumber numberWithInt:[uploadContent noteId]]] setObject:uploadContent forKey:uploadContent.fileURL];
    }
    NSLog(@"UploadMan: adding contentForKey:%@ to noteForKey:%d",uploadContent.fileURL,uploadContent.noteId);
}

-(UploadContent *)saveUploadContentToCDWithTitle:(NSString *)title andText:(NSString *)text andType:(NSString *)type andNoteId:(int)noteId andFileURL:(NSURL *)fileURL inState:(NSString *)state
{    
    //PHIL APPROVED
    NSLog(@"UploadMan: Saving Upload Content to CoreData");
    [self deleteUploadContentFromDictionaryFromNoteId:noteId andFileURL:fileURL];
    [self deleteUploadContentFromCDFromNoteId:noteId andFileURL:fileURL]; //Prevent Duplicates
    NSError *error;
    UploadContent *uploadContentCD = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"UploadContent" 
                                      inManagedObjectContext:self.context];
    
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
    //PHIL APPROVED
    NSLog(@"UploadMan: Getting Upload Contents from CoreData");
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" 
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSArray *allUploadContents = [self.context executeFetchRequest:fetchRequest error:&error];
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
    //PHIL APPROVED
    NSLog(@"UploadMan: New UploadContent- NoteId:%d, Title:%@, Text:%@, Type:%@, URL:%@", noteId, title, text, type, aUrl);
    BOOL youreOnWifi =  YES;
    UploadContent *uc = [[uploadContentsForNotes objectForKey:[NSNumber numberWithInt:noteId]] objectForKey:aUrl];
    Reachability *wifiReach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus wifi = [wifiReach currentReachabilityStatus];
    if(wifi == NotReachable)
        youreOnWifi = NO;
    NSData *fileData = [NSData dataWithContentsOfURL:aUrl];
    NSUInteger bytes = fileData.length;
    if (bytes>500000 && !youreOnWifi && !uc) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadManDelayedKey", @"") message:NSLocalizedString(@"UploadManDelayedMessageKey", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
        [alert show];
        uc = [self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateFAILED"];
        [self insertUploadContentIntoDictionary:uc];
        
    }
    else{
        if(self.currentUploadCount < self.maxUploadCount)
        {
            uc = [self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateUPLOADING"];
            [self insertUploadContentIntoDictionary:uc];
            self.currentUploadCount++;
            
            if(text)
            {
                [[AppServices sharedAppServices] addContentToNoteWithText:text type:type mediaId:0 andNoteId:noteId andFileURL:aUrl];
            }
            else
            {            
                [[AppServices sharedAppServices] uploadContentToNoteWithFileURL:aUrl name:nil noteId:noteId type:type]; 
            }
        }
        else {
            uc = [self saveUploadContentToCDWithTitle:title andText:text andType:type andNoteId:noteId andFileURL:aUrl inState:@"uploadStateQUEUED"];
            [self insertUploadContentIntoDictionary:uc];
        }
    }
}

- (void) contentFinishedUploading
{
    //PHIL APPROVED
    NSLog(@"UploadMan: Upload Content finished uploading");
    self.currentUploadCount--;
    NSArray *noteIdKeyArray =  [self.uploadContentsForNotes allKeys];
    for (int i=0; i < [noteIdKeyArray count]; i++) {
        NSArray *contentIdKeyArray = [[self.uploadContentsForNotes objectForKey:[noteIdKeyArray objectAtIndex:i]] allKeys];
        for (int j=0; j < [contentIdKeyArray count]; j++) {
            UploadContent * uc = [[self.uploadContentsForNotes objectForKey:[ noteIdKeyArray objectAtIndex:i]] objectForKey:[ contentIdKeyArray objectAtIndex:j]];
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
    NSLog(@"UploadMan: Upload Content failed uploading");
    NSArray *noteIdKeyArray =  [self.uploadContentsForNotes allKeys];
    for (int i=0; i < [noteIdKeyArray count]; i++) {
        NSArray *contentIdKeyArray = [[self.uploadContentsForNotes objectForKey:[noteIdKeyArray objectAtIndex:i]] allKeys];
        for (int j=0; j < [contentIdKeyArray count]; j++) {
            UploadContent * uc = [[self.uploadContentsForNotes objectForKey:[ noteIdKeyArray objectAtIndex:i]] objectForKey:[ contentIdKeyArray objectAtIndex:j]];
            uc.state = @"uploadStateFAILED";
            
            UploadContent * newuc = [self saveUploadContentToCDWithTitle:[uc getTitle] andText:[uc getText] andType:[uc getType] andNoteId:[uc getNoteId] andFileURL:uc.fileURL inState:@"uploadStateFAILED"];
            [self insertUploadContentIntoDictionary:newuc];
        }
    }
    self.currentUploadCount--; //Resume Possibility of new uploads
}

- (void) deleteContentFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
    //PHIL APPROVED
    NSLog(@"UploadMan: Deleting Upload Content from note");
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
    NSLog(@"UploadMan: init");
    self = [super init];
    if (self) {
        currentUploadCount = 0;
        maxUploadCount = 1;
        uploadContentsForNotes = [[NSMutableDictionary alloc] initWithCapacity:5];
        context = [AppModel sharedAppModel].managedObjectContext;
        [self deleteAllObjects:@"UploadContent"]; //UNCOMMENT TO DELETE ALL CORE DATA STUFF
        [self getSavedUploadContents];
    }
    return self;
}

@end