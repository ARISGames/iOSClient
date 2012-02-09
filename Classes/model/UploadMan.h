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
    NSMutableDictionary *uploadContents;
    NSManagedObjectContext *context;    
}

@property (nonatomic, retain) NSMutableDictionary *uploadContents;
@property (nonatomic, retain) NSManagedObjectContext *context;

- (void) uploadContentForNote:(NSNumber *)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSString *)url;
- (void) deleteContentFromNote:(NSNumber *)noteId andFileURL:(NSString *)fileURL;

@end