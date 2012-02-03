//
//  AsyncImageView.h
//  ARIS
//
//  Created by David J Gagnon on 11/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "ARISMoviePlayerViewController.h"

@interface AsyncImageView : UIImageView {
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	Media *media; //keep a refrence so we can update the media with the data after it is loaded
    NSObject *delegate;
	BOOL isLoading;
    BOOL loaded;
    ARISMoviePlayerViewController *mMoviePlayer;
    UIButton *mediaPlayBackButton;
    CGRect aframe;
}

@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) Media *media;
@property (nonatomic, assign) NSObject *delegate;
@property(readwrite,assign)BOOL isLoading;
@property(readwrite,assign)BOOL loaded;
@property(nonatomic,retain)ARISMoviePlayerViewController *mMoviePlayer;
@property(nonatomic,retain)UIButton *mediaPlayBackButton;
@property(readwrite, assign)CGRect aframe;


- (void) loadImageFromMedia:(Media *) aMedia;
- (UIImage*) getImage;
- (void) setImage:(UIImage*) image;
- (void) updateViewWithNewImage:(UIImage*)image;
-(void)initWithMediaId:(int)mediaId andFrame:(CGRect)aFrame andDelegate:(id)delegateToPresentMoviePlayer;
-(void)movieThumbDidFinish:(NSNotification*) aNotification;
-(void)playMovie:(id)sender;
@end


