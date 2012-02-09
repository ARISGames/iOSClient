//
//  UploadContent.h
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#include "NoteContentProtocol.h"
#include "Media.h"


@interface UploadContent : NSManagedObject <NoteContentProtocol>

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *localFileURL;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *note_id;
@property (nonatomic, retain) NSNumber *attemptfailed;

- (id) initForNote:(NSNumber *)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSString *)url hasAttemptedUpload:(BOOL)attemptFailed andContext:(NSManagedObjectContext *)context;

@end
