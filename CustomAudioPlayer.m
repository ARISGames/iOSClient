//
//  CustomAudioPlayer.m
//  ARIS
//
//  Created by Brian Thiel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomAudioPlayer.h"
#import "Media.h"
#import "AppModel.h"

@implementation CustomAudioPlayer
@synthesize timeLabel,playButton,soundPlayer,mediaId;
- (id)initWithFrame:(CGRect)frame andMediaId:(int)mediaID
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFrame:frame];
        self.mediaId = mediaID;
        self.soundPlayer = [[AVPlayer alloc] init];
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 40, 40)];
        self.timeLabel.font = [UIFont boldSystemFontOfSize:18];
        self.timeLabel.textColor = [UIColor darkGrayColor];
           }
    return self;
}
-(void)loadView{
    [self setBackgroundColor:[UIColor clearColor]];
    [self.playButton setFrame:CGRectMake(0, 0, 36, 36)];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"stop_button.png"] forState:UIControlStateSelected];
    [self.timeLabel setBackgroundColor:[UIColor clearColor]];
    [self.playButton addTarget:self action:@selector(playButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [[AVAudioSession sharedInstance] setDelegate: self];
    [self addSubview:self.playButton];
    [self addSubview: self.timeLabel];

}
-(void)removeObs{
    [self.soundPlayer removeTimeObserver:timeObserver];

}
-(void)playButtonTouch{
    Media *media = [[Media alloc] init];
    media = [[AppModel sharedAppModel] mediaForMediaId:self.mediaId];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
    
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    
    //NSError *error;
    if(self.soundPlayer.rate == 1.0f){
        [self.soundPlayer pause];
        timeLabel.text = nil;
        
        playButton.selected = NO;
    }
    else{
        NSURL *url =  [NSURL URLWithString:media.url];
        [self.soundPlayer initWithURL:url]; 
        [self.soundPlayer play];
        playButton.selected = YES;

    }
    
    CMTime time = CMTimeMakeWithSeconds(1.0f, 1);
    
    timeObserver = [[self.soundPlayer addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ 
        if((self.soundPlayer.currentTime.value != self.soundPlayer.currentItem.duration.value) && self.soundPlayer.rate !=0.0f){  
            timeLabel.text =[NSString stringWithFormat:@"%d:%d%d", (int)roundf(CMTimeGetSeconds(self.soundPlayer.currentTime))/60,((int)roundf(CMTimeGetSeconds(self.soundPlayer.currentTime))) % 60/10,(int)roundf(CMTimeGetSeconds(self.soundPlayer.currentTime))%10];
        }else {
            timeLabel.text = nil;
            playButton.selected = NO;
            [self removeObs];
        }
    } ] retain];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.soundPlayer = nil;
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	NSLog(@"AudioRecorder: Playback Error");
}
@end
