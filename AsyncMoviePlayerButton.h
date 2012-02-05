//
//  AsyncMoviePlayerButton.h
//  ARIS
//
//  Created by David Gagnon on 2/4/12.
//  Copyright (c) 2012 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "ARISMoviePlayerViewController.h"

@interface AsyncMoviePlayerButton : UIButton {
    Media *media; //keep a refrence so we can update the media with the data after it is loaded
    ARISMoviePlayerViewController *mMoviePlayer;
    UIViewController *presentingController;
}


-(id)initWithFrame:(CGRect)frame mediaId:(int)mediaId presentingController:(UIViewController*)aPresentingController;
    
@property (nonatomic, retain) Media *media;
@property (nonatomic, retain) ARISMoviePlayerViewController *mMoviePlayer;
@property (nonatomic, retain) UIViewController *presentingController;


@end
