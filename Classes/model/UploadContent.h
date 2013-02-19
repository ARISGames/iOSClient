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

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSURL *fileURL;
@property int noteId;

@end

@interface UploadContent (CoreDataGeneratedPrimitiveAccessors)

- (NSString *) primitiveState;
- (void) setPrimitiveState:(NSString *)value;

- (NSString *) primitiveFileURL;
- (void) setPrimitiveFileURL:(NSString *)value;

- (NSNumber *) primitiveNoteId;
- (void) setPrimitiveNoteId:(NSNumber *)value;

@end