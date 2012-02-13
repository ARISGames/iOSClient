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


-(void)saveUploadContentToCD:(UploadContent *)uploadContent
{
    NSLog(@"UploadMan:saveUploadContentToCD"); 
    NSError *error;
    UploadContent *uploadContentCD = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"UploadContent" 
                                      inManagedObjectContext:context];
    
    uploadContentCD.text = uploadContent.text;
    uploadContentCD.title = uploadContent.title;
    uploadContentCD.type = uploadContent.type;
    uploadContentCD.noteId = uploadContent.noteId;
    uploadContentCD.fileURL = uploadContent.fileURL;
    uploadContentCD.attemptFailed = uploadContent.attemptFailed;
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
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
        [self insertUploadContentIntoDictionary:uploadContent];
    }
    [allUploadContents release];
    [fetchRequest release];
}

- (void) deleteUploadContentFromDictionaryFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
    [(NSMutableDictionary *)[uploadContents objectForKey:[NSNumber numberWithInt: noteId]] removeObjectForKey:fileURL];
    if([[(NSMutableDictionary *)[uploadContents objectForKey:[NSNumber numberWithInt: noteId]] allValues] count] == 0)
    {
        [uploadContents removeObjectForKey:[NSNumber numberWithInt: noteId]];
    }
}

- (void) deleteUploadContentFromCDFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" inManagedObjectContext:[AppModel sharedAppModel].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppModel sharedAppModel].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
        NSURL *objectURL = [(UploadContent *)managedObject fileURL];
        if([objectURL isEqual:fileURL])
        {
            [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
            NSLog(@"%@ object deleted",@"UploadContent");
        }
    }
    if (![[AppModel sharedAppModel].managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",@"UploadContent",error);
    }

}

#pragma mark Header Implementations

- (void) uploadContentForNoteId:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)aUrl
{
    UploadContent *uploadContent = [[UploadContent alloc] initForNoteId:noteId withTitle:title withText:text withType:type withFileURL:aUrl hasAttemptedUpload:NO andContext:context];
    
    [self saveUploadContentToCD:uploadContent];
    [self insertUploadContentIntoDictionary:uploadContent];
    [uploadContent release];
    
    if(text)
    {
        [[AppServices sharedAppServices]addContentToNoteWithText:text type:type mediaId:0 andNoteId:noteId andFileURL:aUrl];
    }
    else
    {
        [[AppServices sharedAppServices]uploadContentToNoteWithFileURL:aUrl name:nil noteId:noteId type:type];       
    }
    
}

- (void) deleteContentFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
    [self deleteUploadContentFromDictionaryFromNoteId:noteId andFileURL:fileURL];
    [self deleteUploadContentFromCDFromNoteId:noteId andFileURL:fileURL];
}

- (id)init
{
    self = [super init];
    if (self) {
        uploadContents = [[NSMutableDictionary alloc] initWithCapacity:5];
        context = [AppModel sharedAppModel].managedObjectContext;
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