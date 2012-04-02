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

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *state;
@property (nonatomic) NSURL *fileURL;
@property (nonatomic) Media *media;
@property int noteId;

- (id) initForNoteId:(int)noteId withTitle:(NSString *)title withText:(NSString *)text withType:(NSString *)type withFileURL:(NSURL *)url inState:(NSString *)state andContext:(NSManagedObjectContext *)context;

@end


@interface UploadContent (PrimitiveAccessors)


- (NSString *) primitiveFileURL;
- (void) setPrimitiveFileURL:(NSString *)value;

- (NSNumber *) primitiveNoteId;
- (void) setPrimitiveNoteId:(NSNumber *)value;

@end
