//
//  UploadMan.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadMan.h"

@implementation UploadMan
@synthesize uploadContents;
@synthesize context;

- (void) uploadContent
{
    
}

-(void)getSavedUploadContents
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadContent" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    self.uploadContents = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
}

-(void)saveUploadContentForNote:(NSNumber *)noteId withTitle:(NSString *) title withText:(NSString *)text withType:(NSString *)type andFileURL:(NSString *)url
{
    NSError *error;
    UploadContent *uploadContent = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"UploadContent" 
                                    inManagedObjectContext:context];
    uploadContent.text = text;
    uploadContent.title = title;
    uploadContent.type = type;
    uploadContent.fileURL = url;
    uploadContent.note_id = noteId;
    uploadContent.attemptfailed = false;
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        context = [AppModel sharedAppModel].managedObjectContext;
        [self getSavedUploadContents];
    }
    return self;
}

- (void)dealloc {
    [context release];
    [super dealloc];
}

@end