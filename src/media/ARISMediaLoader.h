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
    id <ARISMediaLoaderDelegate> __unsafe_unretained delegate; 
};
@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) id<ARISMediaLoaderDelegate> delegate;

- (void) cancelConnection;

@end

@interface ARISMediaLoader : NSObject

- (id) init;
- (void) loadMedia:(Media *)m delegate:(id<ARISMediaLoaderDelegate>)d;
- (void) loadMediaFromId:(int)m ofType:(NSString *)t delegate:(id<ARISMediaLoaderDelegate>)d;

@end
