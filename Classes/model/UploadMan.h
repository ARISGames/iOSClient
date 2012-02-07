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
    NSArray *uploadContents;
    NSManagedObjectContext *context;    
}

@property (nonatomic, retain) NSArray *uploadContents;
@property (nonatomic, retain) NSManagedObjectContext *context;

- (void) uploadContent;

@end