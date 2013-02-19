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
@property(nonatomic, strong) NSNumber *gameid;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSData *image;
@property(nonatomic, strong) NSNumber *uid;


@end


