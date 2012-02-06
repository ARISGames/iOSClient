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


@interface UploadContent : NSManagedObject <NoteContentProtocol>

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSData * media;
@property (nonatomic, retain) NSNumber * note_id;
@property (nonatomic, retain) NSNumber * attemptfailed;

@end
