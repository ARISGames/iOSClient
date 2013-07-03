//
//  AsyncMediaImageView.h
//  ARIS
//
//  Created by David J Gagnon on 11/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@class AsyncMediaImageView;

@protocol AsyncMediaImageViewDelegate <NSObject>
@optional
-(void) imageFinishedLoading:(AsyncMediaImageView *)image;
@end

@interface AsyncMediaImageView : UIImageView
{
    BOOL isLoading;
}

@property (readwrite, assign) BOOL isLoading;

- (id) initWithMediaId:(int)mediaId;
- (id) initWithMedia:(Media *)aMedia;
- (id) initWithFrame:(CGRect)aFrame andMediaId:(int)mediaId;
- (id) initWithFrame:(CGRect)aFrame andMedia:(Media *)aMedia;
- (id) initWithFrame:(CGRect)aFrame andMediaId:(int)mediaId andDelegate:(id<AsyncMediaImageViewDelegate>)d;
- (id) initWithFrame:(CGRect)aFrame andMedia:(Media *)aMedia andDelegate:(id<AsyncMediaImageViewDelegate>)d;
- (void) setDelegate:(id<AsyncMediaImageViewDelegate>)d;

- (void) loadMedia:(Media *)aMedia;
- (void) cancelLoad;
- (void) setImage:(UIImage*)image;
- (void) updateViewWithNewImage:(UIImage*)image;

@end
