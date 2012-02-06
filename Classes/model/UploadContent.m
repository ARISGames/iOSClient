//
//  UploadContent.m
//  ARIS
//
//  Created by Philip Dougherty on 2/3/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import "UploadContent.h"

@implementation UploadContent

@dynamic text;
@dynamic media;
@dynamic note_id;
@dynamic attemptfailed;

- (NSData *) getMedia
{
    return [self media];
}

- (NSString *) getText
{
    return [self text];
}

@end
