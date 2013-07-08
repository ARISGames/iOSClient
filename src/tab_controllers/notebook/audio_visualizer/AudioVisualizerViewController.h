//
//  AudioVisualizerViewController.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveSampleProvider.h"
#import "AudioSlider.h"
#include <AVFoundation/AVFoundation.h>
#import "WaveformControl.h"
#import "FreqHistogramControl.h"


@interface AudioVisualizerViewController : UIViewController<WaveSampleProviderDelegate, WaveformControlDelegate, FreqHistogramControlDelegate, UIAlertViewDelegate>{
	WaveSampleProvider *wsp;
	AVPlayer *player;
	NSString *infoString;
	NSString *timeString;
	UIColor *green;
	UIColor *gray;
	UIColor *lightgray;
	UIColor *darkgray;
	UIColor *white;
	UIColor *marker;
    

}
@property (nonatomic) CGPoint* sampleData;
@property (nonatomic) int sampleLength;
@property (nonatomic) float playProgress;
@property (nonatomic) float endTime;
@property (nonatomic) int lengthInSeconds;

- (void) openAudioURL:(NSURL *)url;
-(void)setPlayHeadToLeftSlider;
- (void) pauseAudio;



@end
