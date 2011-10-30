//
//  AsyncImageView.h
//  ARIS
//
//  Created by David J Gagnon on 11/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@interface AsyncImageView : UIImageView {
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	Media *media; //keep a refrence so we can update the media with the data after it is loaded
    NSObject *delegate;
	BOOL isLoading;
    BOOL loaded;
}

@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) Media *media;
@property (nonatomic, assign) NSObject *delegate;
@property(readwrite,assign)BOOL isLoading;
@property(readwrite,assign)BOOL loaded;

- (void) loadImageFromMedia:(Media *) aMedia;
- (UIImage*) getImage;
- (void) setImage:(UIImage*) image;
- (void) updateViewWithNewImage:(UIImage*)image;

@end


