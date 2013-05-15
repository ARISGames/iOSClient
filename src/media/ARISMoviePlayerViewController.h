//
//  ARISMoviePlayerViewController.h
//  ARIS
//
//  Created by David J Gagnon on 6/22/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface ARISMoviePlayerViewController : MPMoviePlayerViewController {
    UIButton *mediaPlaybackButton;
}
@property(nonatomic, strong) UIButton *mediaPlaybackButton;
@end
