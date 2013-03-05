//
//  AsyncMediaPlayerButton.h
//  ARIS
//
//  Created by David Gagnon on 2/4/12.
//  Copyright (c) 2012 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "ARISMoviePlayerViewController.h"

@interface AsyncMediaPlayerButton : UIButton
{
    Media *media; //keep a refrence so we can update the media with the data after it is loaded
    ARISMoviePlayerViewController *mMoviePlayer;
    UIViewController *__unsafe_unretained presentingController;
    bool preloadOnInit;
}

-(id)initWithFrame:(CGRect)frame media:(Media *)media presentingController:(UIViewController*)aPresentingController preloadNow:(BOOL)preload;

-(id)initWithFrame:(CGRect)frame mediaId:(int)mediaId presentingController:(UIViewController*)aPresentingController preloadNow:(BOOL)preload;

@property (nonatomic) Media *media;
@property (nonatomic) ARISMoviePlayerViewController *mMoviePlayer;
@property (nonatomic, unsafe_unretained) UIViewController *presentingController;
@property (nonatomic) bool preloadOnInit;

@end
