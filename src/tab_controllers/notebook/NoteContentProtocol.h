//
//  NoteContentProtocol.h
//  ARIS
//
//  Created by Philip Dougherty on 2/6/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Media;
@protocol NoteContentProtocol
- (NSString *) getTitle;
- (NSString *) getText;
- (NSString *) getType;
- (NSString *) getUploadState; //uploadStateDONE, uploadStateUPLOADING, uploadStateQUEUED, uploadStateFAILED
- (Media *) getMedia;
- (int) getNoteId;
- (int) getContentId;
- (id) managedObjectContext;
- (NSString *) description;
@end
