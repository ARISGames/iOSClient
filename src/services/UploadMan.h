//
//  UploadMan.h
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadContent.h"
#import "Media.h"

@interface UploadMan : NSObject {    
    NSMutableDictionary *uploadContentsForNotes;
    NSManagedObjectContext *context;   
    int currentUploadCount;
    int maxUploadCount;
}

@property (nonatomic, strong) NSMutableDictionary *uploadContentsForNotes;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic) int currentUploadCount;
@property (nonatomic) int maxUploadCount;

- (void) uploadContentForNoteId:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)url;
- (void) uploadPlayerPicContentWithFileURL:(NSURL *)aUrl;
- (void) contentFinishedUploading;
- (void) contentFailedUploading;
- (void) uploadAllFailedContent;
- (void) checkForFailedContent;
- (void) deleteContentFromNoteId:(int)noteId andFileURL:(NSURL *)fileURL;

@end