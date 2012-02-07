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
@property (nonatomic, retain) NSString *fileURL;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *note_id;
@property (nonatomic, retain) NSNumber *attemptfailed;

@end
