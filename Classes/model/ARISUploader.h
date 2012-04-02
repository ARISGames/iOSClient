//
//  ARISUploader.h
//  ARIS
//
//  Created by Garrett Smith on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface ARISUploader : NSObject {
    NSURL* urlToUpload;
    NSURL *serverURL;
    NSDictionary *userInfo;
    id delegate;
    SEL doneSelector;
    SEL errorSelector;
    
    
    BOOL uploadDidSucceed;
    NSString *responseString;
    NSError *error;


}

- (id)initWithURLToUpload:(NSURL*) urlToUpload delegate:(id)delegate 
             doneSelector: (SEL)doneSelector errorSelector: (SEL)errorSelector;
- (void)upload;

@property(nonatomic,retain) NSDictionary *userInfo;
@property(nonatomic,retain) NSString *responseString;
@property(nonatomic,retain) NSError *error;

@end