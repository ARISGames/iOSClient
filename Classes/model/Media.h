//
//  Media.h
//  ARIS
//
//  Created by Kevin Harris on 9/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const kMediaTypeVideo;
extern NSString *const kMediaTypeImage;
extern NSString *const kMediaTypeAudio;

@interface Media : NSManagedObject 
@property(nonatomic, retain) NSString	*url;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSData *image;
@property(nonatomic, retain) NSNumber *uid;


@end


