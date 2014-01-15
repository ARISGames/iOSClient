//
//  AudioVisualizerViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

/*
#import "AudioVisualizerViewController.h"
#import "WaveformControl.h"
#import "FreqHistogramControl.h"
#import "AudioTint.h"
#import <Accelerate/Accelerate.h>
#import "AppModel.h"
#import "UIColor+ARISColors.h"
#import "Playhead.h"
#import "ARISAlertHandler.h"
#import "WaveSampleProvider.h"
#import "AudioSlider.h"
#include <AVFoundation/AVFoundation.h>
#import "WaveformControl.h"
#import "FreqHistogramControl.h"
#import "Playhead.h"

#define SLIDER_BUFFER 35

@interface AudioVisualizerViewController () <WaveSampleProviderDelegate, WaveformControlDelegate, FreqHistogramControlDelegate, PlayheadControlDelegate, UIAlertViewDelegate>
{
    UIToolbar *toolbar;
    UIButton *withoutBorderButton;
    UIButton *withoutBorderButtonStop;
    UIButton *withoutBorderButtonSwap;
    UIBarButtonItem *playButton;
    UIBarButtonItem *stopButton;
    UIBarButtonItem *swapButton;
    AudioSlider *leftSlider;
    AudioSlider *rightSlider;
    AudioTint *leftTint;
    AudioTint *rightTint;
    WaveformControl *wf;
    FreqHistogramControl *freq;
    Playhead *playHead;
    id timeObserver;
    UILabel *timeLabel;
    UIBarButtonItem *timeButton;
    Float64 duration;

    
    UILabel *freqLabel;
    UIBarButtonItem *freqButton;
    
    ExtAudioFileRef extAFRef;
    int extAFNumChannels;
    NSURL *audioURL;
    Float64 sampleRate;
    int numBins;
    
	WaveSampleProvider *wsp;
	AVPlayer *player;
	NSString *infoString;
	NSString *timeString;
    
    id<AudioVisualizerViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation AudioVisualizerViewController

- (id) initWithAudioURL:(NSURL *)u delegate:(id<AudioVisualizerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadAudioForPath:inputOutputPathURL];
    audioURL = inputOutputPathURL;
    OSStatus err;
	CFURLRef inpUrl = (__bridge CFURLRef)audioURL;
	err = ExtAudioFileOpenURL(inpUrl, &extAFRef);
	if(err != noErr) {
		NSLog(@"Cannot open audio file");
		return;
	}

    //this is a giant hack that causes the current view controller to re-evaluate the orientation its in.
    //change if a better way is found for forcing the orientation to initially be in landscape
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    ARISViewController *root = (ARISViewController *)window.rootViewController;
    window.rootViewController = nil;
    window.rootViewController = root;
    [ARISViewController attemptRotationToDeviceOrientation];

    CGRect frame = self.navigationController.navigationBar.frame;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        frame.size.height = 32;
    }
    self.navigationController.navigationBar.frame = frame;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) initView
{
    numBins = 512;
    sampleRate = 44100.0f;
	playProgress = 0.0;
	green     = [UIColor colorWithRed:143.0/255.0 green:196.0/255.0 blue:72.0/255.0 alpha:1.0];
	gray      = [UIColor colorWithRed:64.0/255.0 green:63.0/255.0 blue:65.0/255.0 alpha:1.0];
	lightgray = [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
	darkgray  = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:48.0/255.0 alpha:1.0];
	white     = [UIColor whiteColor];
	marker    = [UIColor colorWithRed:242.0/255.0 green:147.0/255.0 blue:0.0/255.0 alpha:1.0];

    freq = [[FreqHistogramControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, self.view.bounds.size.height + 12)];
    freq.delegate = self;
    [self.view addSubview:freq];
    
    wf = [[WaveformControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, self.view.bounds.size.height + 12)];
    wf.delegate = self;
    [self.view addSubview:wf];
    
    playHead = [[Playhead alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, self.view.bounds.size.height + 12)];
    playHead.delegate = self;
    [self.view addSubview:playHead];

    
    
    leftSlider = [[AudioSlider alloc] init];
    leftSlider.frame = CGRectMake(-17.5, 0, 35.0, self.view.bounds.size.height + 12);
    [leftSlider addTarget:self action:@selector(draggedOut:withEvent:)
         forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];

    rightSlider = [[AudioSlider alloc] init];
    rightSlider.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 17.5, 0, 35.0, self.view.bounds.size.height + 12);
    [rightSlider addTarget:self action:@selector(draggedOut:withEvent:)
          forControlEvents:UIControlEventTouchDragOutside |
     UIControlEventTouchDragInside];
    
    
    leftTint = [[AudioTint alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, 12, leftSlider.center.x, self.view.bounds.size.height)];
    [self.view addSubview:leftTint];
    [self.view addSubview:leftSlider];
    
    rightTint = [[AudioTint alloc] initWithFrame:CGRectMake(rightSlider.center.x, 12, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:rightTint];
    [self.view addSubview:rightSlider];
    
    toolbar = [[UIToolbar alloc]init];
    toolbar.frame = CGRectMake(self.view.bounds.origin.x, wf.bounds.size.height, self.view.bounds.size.width, 44);
    
    withoutBorderButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
    playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    
    withoutBorderButtonStop = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButtonStop setImage:[UIImage imageNamed:@"35-circle-stop"] forState:UIControlStateNormal];
    [withoutBorderButtonStop addTarget:self action:@selector(stopFunction) forControlEvents:UIControlEventTouchUpInside];
    stopButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButtonStop];
    
    withoutBorderButtonSwap = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [withoutBorderButtonSwap setImage:[UIImage imageNamed:@"05-shuffle"] forState:UIControlStateNormal];
    [withoutBorderButtonSwap addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    swapButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButtonSwap];
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 125, 25)];
    [timeLabel setText:timeString];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    timeButton = [[UIBarButtonItem alloc] initWithCustomView:timeLabel];
    
    freqLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 125, 25)];
    [freqLabel setText:@""];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor ARISColorBlack]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqButton = [[UIBarButtonItem alloc]initWithCustomView:freqLabel];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    //Normal Screen - 480
    //fixedSpace.width = 42;//42*3=128 ; 480-128=352 -> ([UIScreen mainScreen].bounds.size.height - 352)/4
    //4 Inch Screen - 568
    //fixedSpace.width = 72;//72*3=216 ; 568-216=352 -> ([UIScreen mainScreen].bounds.size.height - 352)/4
    fixedSpace.width = ([UIScreen mainScreen].bounds.size.height - 352)/4;
    
    NSArray *toolbarButtons = [NSArray arrayWithObjects:playButton, stopButton, fixedSpace, timeButton, fixedSpace, freqButton, fixedSpace, swapButton, nil];
    [toolbar setItems:toolbarButtons animated:NO];
    [self.view addSubview:toolbar];
    
    endTime = 1.0;
    
    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAudioConfirmation)];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;
    
}

- (void) draggedOut: (UIControl *) c withEvent: (UIEvent *) ev {
    
    [self stopFunction];
    CGPoint point = [[[ev allTouches] anyObject] locationInView:self.view];

    if(point.x > 0 && point.x < self.view.bounds.size.width){
        if([c isEqual:leftSlider]){
            if(rightSlider.center.x - point.x > SLIDER_BUFFER){
                c.center = CGPointMake(point.x, c.center.y);
            }
            else{
                c.center = CGPointMake(rightSlider.center.x - SLIDER_BUFFER, c.center.y);
            }
            if(player.rate == 0.0){
                [self setPlayHeadToLeftSlider];
            }
            leftTint.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, leftSlider.center.x, self.view.bounds.size.height);
            [leftTint setNeedsDisplay];
        }
        else{
            if(leftSlider.center.x - point.x < -SLIDER_BUFFER){
                c.center = CGPointMake(point.x, c.center.y);
            }
            else{
                c.center = CGPointMake(leftSlider.center.x + SLIDER_BUFFER, c.center.y);
            }
            rightTint.frame = CGRectMake(rightSlider.center.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
            [rightTint setNeedsDisplay];

            CGFloat x = rightSlider.center.x - self.view.bounds.origin.x;
            float sel = x / self.view.bounds.size.width;
            endTime = sel;
            if(endTime <= playProgress){
                [self setPlayHeadToLeftSlider];
            }
        }

    }
}

-(void)playFunction{
    if(player.rate == 0.0){
        [withoutBorderButton setImage:[UIImage imageNamed:@"29-circle-pause"] forState:UIControlStateNormal];
        [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
        playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    }
    else{
        [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play"] forState:UIControlStateNormal];
        [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
        playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    }
    [self pauseAudio];
    [self updateTimeString];
}

-(void)stopFunction{
    if(player.rate != 0.0){
        [self pauseAudio];
        [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play"] forState:UIControlStateNormal];
        [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
        playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
        [player removeTimeObserver:timeObserver];
        [self addTimeObserver];
        [self setPlayHeadToLeftSlider];
    }
}

-(void)setPlayHeadToLeftSlider{
    CGFloat x = leftSlider.center.x - self.view.bounds.origin.x;
    float sel = x / self.view.bounds.size.width;
    duration = CMTimeGetSeconds(player.currentItem.duration);
    float timeSelected = duration * sel;
    CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
    [player seekToTime:tm];
}

-(void)loadAudioForPath:(NSURL *)pathURL{
    if(pathURL == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Audio!"
                                                        message: @"Sorry, the audio visualizer failed to load the audio"
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:@"Loading Audio..."];
        [self openAudioURL:pathURL];
    }

}

-(void)updateTimeString{
    duration = CMTimeGetSeconds(player.currentItem.duration);
    Float64 currentTime = CMTimeGetSeconds(player.currentTime);
    int dmin = duration / 60;
    int dsec = duration - (dmin * 60);
    int cmin = currentTime / 60;
    int csec = currentTime - (cmin * 60);
    [self setTimeString:[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",cmin,csec,dmin,dsec]];
    playProgress = currentTime/duration;
}

- (void) setTimeString:(NSString *)newTime
{
	timeString = newTime;
    [timeLabel setText:timeString];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor ARISColorBlack]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    timeButton = [[UIBarButtonItem alloc] initWithCustomView:timeLabel];
}

- (void) openAudioURL:(NSURL *)url
{
	if(player != nil) {
		[player pause];
		player = nil;
	}
	sampleLength = 0;
	[wf setNeedsDisplay];
	wsp = [[WaveSampleProvider alloc]initWithURL:url];
	wsp.delegate = self;
	[wsp createSampleData];
}

- (void) pauseAudio
{
	if(player == nil) {
		[self startAudio];
		[player play];
	} else {
		if(player.rate == 0.0) {
			[player play];
		} else {
			[player pause];
		}
	}
}

- (void) startAudio
{
	if(wsp.status == LOADED) {
		player = [[AVPlayer alloc] initWithURL:wsp.audioURL];
		[self addTimeObserver];
	}
}

-(void)addTimeObserver{
    CMTime tm = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
    __weak id weakSelf = self;
    __weak id weakPlayHead = playHead;
    __weak id weakWf = wf;
    timeObserver = [player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf updateTimeString];
        if(![weakPlayHead isHidden]){
            [weakPlayHead setNeedsDisplay];
        }
        if([weakWf isHidden]){
            [weakSelf loadAudio];
        }
        if([weakSelf getPlayProgress] >= [weakSelf getEndTime]){
            [weakSelf clipOver];
        }
    }];
}


- (void) setSampleData:(float *)theSampleData length:(int)length
{
	sampleLength = 0;
	
	length += 2;
	CGPoint *tempData = (CGPoint *)calloc(sizeof(CGPoint),length);
	tempData[0] = CGPointMake(0.0,0.0);
	tempData[length-1] = CGPointMake(length-1,0.0);
	for(int i = 1; i < length-1;i++) {
		tempData[i] = CGPointMake(i, theSampleData[i]);
	}
	
	CGPoint *oldData = sampleData;
	
	sampleData = tempData;
	sampleLength = length;
	
	if(oldData != nil) {
		free(oldData);
	}
	
	free(theSampleData);
	[wf setNeedsDisplay];
    [freq setNeedsDisplay];
}

#pragma mark Orientation

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark -
#pragma mark Sample Data Provider Delegate
- (void) statusUpdated:(WaveSampleProvider *)provider
{
	//[self setInfoString:wsp.statusMessage];
}

- (void) sampleProcessed:(WaveSampleProvider *)provider
{
	if(wsp.status == LOADED) {
        [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
		int sdl = 0;
		//		float *sd = [wsp dataForResolution:[self waveRect].size.width lenght:&sdl];
		float *sd = [wsp dataForResolution:8000 lenght:&sdl];
		[self setSampleData:sd length:sdl];
		int dmin = wsp.minute;
		int dsec = wsp.sec;
		[self setTimeString:[NSString stringWithFormat:@"--:--/%02d:%02d",dmin,dsec]];
		[self startAudio];
	}
}

-(void)setAudioLength:(float)seconds{
    self.lengthInSeconds = seconds;
}



#pragma mark Playhead control delegate

-(void)playheadControl:(Playhead *)playhead wasTouched:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
	CGPoint local_point = [touch locationInView:self.view];
	if(CGRectContainsPoint(self.view.bounds,local_point) && player != nil) {
        CGFloat x = local_point.x - self.view.bounds.origin.x;
        float sel = x / self.view.bounds.size.width;
        duration = CMTimeGetSeconds(player.currentItem.duration);
        float timeSelected = duration * sel;
        CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
        [player seekToTime:tm];
	}
}

-(void)clipOver{
    [self pauseAudio];
    [withoutBorderButton setImage:[UIImage imageNamed:@"30-circle-play"] forState:UIControlStateNormal];
    [withoutBorderButton addTarget:self action:@selector(playFunction) forControlEvents:UIControlEventTouchUpInside];
    playButton = [[UIBarButtonItem alloc]initWithCustomView:withoutBorderButton];
    [player removeTimeObserver:timeObserver];
    [self addTimeObserver];
    [self setPlayHeadToLeftSlider];
}

-(CGPoint *)getSampleData{
    return sampleData;
}

-(int)getSampleLength{
    return sampleLength;
}

-(float)getPlayProgress{
    return playProgress;
}

-(float)getEndTime{
    return endTime;
}

#pragma mark Freq Histogram control delegate
-(void)freqHistogramControl:(WaveformControl *)waveform wasTouched:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    CGPoint local_point = [touch locationInView:freq];
    float binWidth = freq.bounds.size.width / (numBins/2);
    float bin = local_point.x / binWidth;
    
    if(CGRectContainsPoint(freq.bounds,local_point)){
        freq.currentFreqX = local_point.x;
    }
    
    [freq setNeedsDisplay];
    
    [freqLabel setText:[NSString stringWithFormat:@"%.2f Hz", ((bin * sampleRate)/numBins)]];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor ARISColorBlack]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqButton = [[UIBarButtonItem alloc] initWithCustomView:freqLabel];
}

#pragma mark Saving Data

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;{
    if (buttonIndex == 1)
    {
        [self saveAudio];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAudioConfirmation
{
    [player pause];
    UIAlertView *confirmationAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SaveConfirmationKey", nil)
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"DiscardChangesKey", nil)
                                                     otherButtonTitles:NSLocalizedString(@"SaveKey", nil), nil];
    [confirmationAlert show];
}

- (BOOL)saveAudio
{
    float vocalStartMarker  = leftSlider.center.x  / self.view.frame.size.width;
    float vocalEndMarker    = rightSlider.center.x / self.view.frame.size.width;
    
    NSURL *audioFileInput = inputOutputPathURL;
    NSURL *audioFileOutput = [NSURL fileURLWithPath:[intermediatePathString stringByAppendingString:@"trimmed.m4a"]];
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                        presetName:AVAssetExportPresetAppleM4A];
    
    if (exportSession == nil)
    {
        return NO;
    }
    NSLog(@"Left: %f Right: %f",vocalStartMarker,vocalEndMarker);
    
    duration = CMTimeGetSeconds(player.currentItem.duration);
    
    vocalStartMarker *= duration;
    vocalEndMarker *= duration;

    CMTime startTime = CMTimeMake(vocalStartMarker , 1);
    CMTime stopTime = CMTimeMake(vocalEndMarker , 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
             [[NSFileManager defaultManager] removeItemAtURL:audioFileInput error: nil];
             
             [[NSNotificationCenter defaultCenter]
              postNotificationName:@"AudioWasTrimmedNotification"
              object:self];
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // Failed :'[
             NSLog(@"Save didn't work right :'[");
             
             UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SaveErrorTitleKey", nil)
                                                                        message:NSLocalizedString(@"SaveErrorKey", nil)
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"OkKey", nil)
                                                              otherButtonTitles:nil];
             [errorAlert show];
         }
     }];
    
    return YES;
}

#pragma mark Control
- (void) flipView
{
    [self.view.subviews[0] setHidden:[self.view.subviews[2] isHidden]];
    [self.view.subviews[2] setHidden:![self.view.subviews[2] isHidden]];
    if([wf isHidden]){
        float binWidth = freq.bounds.size.width / (numBins/2);
        float bin = freq.currentFreqX / binWidth;
        [freqLabel setText:[NSString stringWithFormat:@"%.2f Hz", ((bin * sampleRate)/numBins)]];
    }
    else{
        [freqLabel setText:@""];
    }
    
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor ARISColorBlack]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqButton = [[UIBarButtonItem alloc]initWithCustomView:freqLabel];
    [leftSlider setHidden:![leftSlider isHidden]];
    [rightSlider setHidden:![rightSlider isHidden]];
    [leftTint setHidden:![leftTint isHidden]];
    [rightTint setHidden:![rightTint isHidden]];
    [playHead setHidden:![playHead isHidden]];
}

#pragma mark Fourier Helper functions

-(void)loadAudio{
    
    extAFNumChannels = 2;
    
    OSStatus err;
    AudioStreamBasicDescription fileFormat;
    UInt32 propSize = sizeof(fileFormat);
    memset(&fileFormat, 0, sizeof(AudioStreamBasicDescription));
    
    err = ExtAudioFileGetProperty(extAFRef, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
	if(err != noErr) {
		NSLog(@"Cannot get audio file properties");
	}
    
    float startingSample = (sampleRate * playProgress * lengthInSeconds);
    
    AudioStreamBasicDescription clientFormat;
    propSize = sizeof(clientFormat);
    
    memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
    clientFormat.mFormatID = kAudioFormatLinearPCM;
    clientFormat.mSampleRate = sampleRate;
    clientFormat.mFormatFlags = kAudioFormatFlagIsFloat;
    clientFormat.mChannelsPerFrame = extAFNumChannels;
    clientFormat.mBitsPerChannel     = sizeof(float) * 8;
    clientFormat.mFramesPerPacket    = 1;
    clientFormat.mBytesPerFrame      = extAFNumChannels * sizeof(float);
    clientFormat.mBytesPerPacket     = extAFNumChannels * sizeof(float);
    
    err = ExtAudioFileSetProperty(extAFRef, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
	if(err != noErr) {
		NSLog(@"Couldn't convert audio file to PCM format");
		return;
	}
    
    err = ExtAudioFileSeek(extAFRef, startingSample);
    if(err != noErr) {
		NSLog(@"Error in seeking in file");
		return;
	}
    
    float *returnData = (float *)malloc(sizeof(float) * 1024);
    
    AudioBufferList bufList;
    bufList.mNumberBuffers = 1;
    bufList.mBuffers[0].mNumberChannels = extAFNumChannels;
    bufList.mBuffers[0].mData = returnData; // data is a pointer (float*) to our sample buffer
    bufList.mBuffers[0].mDataByteSize = 1024 * sizeof(float);
    
    UInt32 loadedPackets = 1024;
    
    err = ExtAudioFileRead(extAFRef, &loadedPackets, &bufList);
    if(err != noErr) {
		NSLog(@"Error in reading the file");
		return;
	}
    
    freq.fourierData = [self computeFFTForData:returnData forSampleSize:1024];
    [freq setNeedsDisplay];
    
}

-(float *)computeFFTForData:(float *)data forSampleSize:(int)bufferFrames{
    
    int bufferLog2 = round(log2(bufferFrames));
    FFTSetup fftSetup = vDSP_create_fftsetup(bufferLog2, kFFTRadix2);
    float *hammingWindow = (float *)malloc(sizeof(float) * bufferFrames);
    vDSP_hamm_window(hammingWindow, bufferFrames, 0);
    float outReal[bufferFrames / 2];
    float outImaginary[bufferFrames / 2];
    COMPLEX_SPLIT out = { .realp = outReal, .imagp = outImaginary };
    vDSP_vmul(data, 1, hammingWindow, 1, data, 1, bufferFrames);
    vDSP_ctoz((COMPLEX *)data, 2, &out, 1, bufferFrames / 2);
    vDSP_fft_zrip(fftSetup, &out, 1, bufferLog2, FFT_FORWARD);
    
    //print out data
    //    for(int i = 1; i < bufferFrames / 2; i++){
    //        float frequency = (i * sampleRate)/bufferFrames;
    //        float magnitude = sqrtf((out.realp[i] * out.realp[i]) + (out.imagp[i] * out.imagp[i]));
    //        float magnitudeDB = 10 * log10(out.realp[i] * out.realp[i] + (out.imagp[i] * out.imagp[i]));
    //        NSLog(@"Bin %i: Magnitude: %f Magnitude DB: %f  Frequency: %f Hz", i, magnitude, magnitudeDB, frequency);
    //    }
    
    //NSLog(@"\nSpectrum\n");
    //    for(int k = 0; k < bufferFrames / 2; k++){
    //        NSLog(@"Frequency %f Real: %f Imag: %f", (k * sampleRate)/bufferFrames, out.realp[k], out.imagp[k]);
    //    }
    
    float *mag = (float *)malloc(sizeof(float) * bufferFrames/2);
    float *phase = (float *)malloc(sizeof(float) * bufferFrames/2);
    float *magDB = (float *)malloc(sizeof(float) * bufferFrames/2);
    
    vDSP_zvabs(&out, 1, mag, 1, bufferFrames/2);
    vDSP_zvphas(&out, 1, phase, 1, bufferFrames/2);
    
    //NSLog(@"\nMag / Phase\n");
    for(int k = 1; k < bufferFrames/2; k++){
        float magnitudeDB = 10 * log10(out.realp[k] * out.realp[k] + (out.imagp[k] * out.imagp[k]));
        magDB[k] = magnitudeDB;
        //NSLog(@"Frequency: %f Magnitude DB: %f", (k * sampleRate)/bufferFrames, magnitudeDB);
        if(magDB[k] > freq.largestMag){
            freq.largestMag = magDB[k];
        }
        //NSLog(@"Frequency: %f Mag: %f Phase: %f", (k * sampleRate)/bufferFrames, mag[k], phase[k]);
    }
    
    return magDB;
}

@end
*/
