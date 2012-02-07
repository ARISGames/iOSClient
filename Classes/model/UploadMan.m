//
//  UploadMan.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadMan.h"
#import "AppModel.h"

@implementation UploadMan
@synthesize uploadContents;
@synthesize context;

-(void)insertUploadContentIntoDictionary:(UploadContent *)uploadContent
{
    if(![self.uploadContents objectForKey:[uploadContent note_id]])
    {
        NSMutableArray *contentForNote = [[NSMutableArray alloc] initWithObjects:uploadContent, nil];
        [uploadContents setObject:contentForNote forKey:[uploadContent note_id]]; 
    }
    else
    {
        [(NSMutableArray *)[self.uploadContents objectForKey:[uploadContent note_id]] addObject:uploadContent];
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
    uploadContentCD.fileURL = uploadContentCD.fileURL;
    uploadContentCD.note_id = uploadContentCD.note_id;
    uploadContentCD.unique_id = uploadContentCD.note_id;
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

- (void) uploadContentForNote:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSString *)url
{
    UploadContent *uploadContent = [[UploadContent alloc] initForNote:noteId withTitle:title withText:text withType:type withFileURL:url hasAttemptedUpload:false andUniqueIdentifier:-1];
    [self saveUploadContentToCD:uploadContent];
    [self insertUploadContentIntoDictionary:uploadContent];
    [uploadContent release];
}

- (id)init
{
    self = [super init];
    if (self) {
        uploadContents = [[NSMutableDictionary alloc] initWithCapacity:5];
        context = [AppModel sharedAppModel].managedObjectContext;
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