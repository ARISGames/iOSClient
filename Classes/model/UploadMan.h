//
//  UploadMan.h
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

@interface UploadMan : NSObject {    
    NSArray *uploadContents;
    NSManagedObjectContext *context;    
}

@property (nonatomic, retain) NSArray *uploadContents;
@property (nonatomic, retain) NSManagedObjectContext *context;


- (id) uploadContent;

@end