//
//  ARISMediaLoader.h
//  ARIS
//
//  Created by Phil Dougherty on 11/21/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Media.h"
#import "ARISDelegateHandle.h"
#import <AVFoundation/AVFoundation.h>

@protocol ARISMediaLoaderDelegate
- (void) mediaLoaded:(Media *)m;
@end

@interface MediaResult : NSObject
{
  Media *media;
  NSMutableData *data;
  NSURL *url;
  NSURLConnection *connection;

  NSDate *start;
  NSTimeInterval time;

  NSArray *delegateHandles;
};
@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, strong) NSArray *delegateHandles;

- (void) cancelConnection;

@end

@interface ARISMediaLoader : NSObject

//Un-enforcable, but supplied delegate handle's delegate must be of type id<ARISMediaLoaderDelegate>
- (void) loadMedia:(Media *)m delegateHandle:(ARISDelegateHandle *)dh;

@end
