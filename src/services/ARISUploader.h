//
//  ARISUploader.h
//  ARIS
//
//  Created by Garrett Smith on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARISUploader : NSObject
{
    NSURL* urlToUpload;
    NSURL *serverURL;
    NSDictionary *userInfo;
    SEL doneSelector;
    SEL errorSelector;
    
    BOOL game;
    BOOL uploadDidSucceed;
    NSString *responseString;
    NSError *error;
}

- (id) initWithURLToUpload:(NSURL*)urlToUpload gameSpecific:(BOOL)game delegate:(id)delegate doneSelector:(SEL)doneSelector errorSelector:(SEL)errorSelector;
- (void) upload;

@property (nonatomic) NSDictionary *userInfo;
@property (nonatomic) NSString *responseString;
@property (nonatomic) NSError *error;

@end
