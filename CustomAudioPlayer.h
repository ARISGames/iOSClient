//
//  CustomAudioPlayer.h
//  ARIS
//
//  Created by Brian Thiel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Media.h"
@interface CustomAudioPlayer : UIView<AVAudioSessionDelegate, AVAudioPlayerDelegate>{
    UIButton *playButton;
    UILabel *timeLabel;
    AVPlayer *soundPlayer;
    id timeObserver;
    int mediaId;
    Media *media;
}
@property(nonatomic)UIButton *playButton;
@property(nonatomic)UILabel *timeLabel;
@property(nonatomic)Media *media;
@property(readwrite) AVPlayer *soundPlayer;
@property(readwrite,assign)int mediaId;
- (id)initWithFrame:(CGRect)frame andMediaId:(int)mediaID;
- (id)initWithFrame:(CGRect)frame andMedia:(Media *)media;

-(void)removeObs;
-(void)playButtonTouch;
-(void)loadView;
@end
