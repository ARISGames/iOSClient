//
//  AudioVisualizerViewController.m
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "AudioVisualizerViewController.h"

#import "WaveSampleProvider.h"
#import "WaveformControl.h"
#import "FreqHistogramControl.h"
#import "AudioSlider.h"
#import "Playhead.h"

#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>

#import "objc/message.h" //needed to change the orientation

#import "PKRevealController.h"
#import "ARISAlertHandler.h"

#define SLIDER_BUFFER 35

@interface AudioVisualizerViewController () <WaveSampleProviderDelegate, WaveformControlDelegate, FreqHistogramControlDelegate, PlayheadControlDelegate, UIAlertViewDelegate>
{
    UIToolbar *toolbar;

    UIButton *playButton;
    UIButton *pauseButton;
    UIButton *stopButton;
    UIButton *swapButton;

    UIBarButtonItem *playPauseBarButton;
    UIBarButtonItem *stopBarButton;
    UIBarButtonItem *swapBarButton;

    UILabel *timeLabel;
    UIBarButtonItem *timeBarButton;
    UILabel *freqLabel;
    UIBarButtonItem *freqBarButton;

    AudioSlider *leftSlider;
    AudioSlider *rightSlider;
    UIView *leftTint;
    UIView *rightTint;

    WaveformControl *wfControl;
    FreqHistogramControl *freqControl;
    Playhead *playHead;

    id timeObserver;
    Float64 duration;
    CGPoint *sampleData;
    float playProgress;
    float endTime;
    int sampleLength;
    int lengthInSeconds;

    int extAFNumChannels;
    NSURL *audioURL;
    Float64 sampleRate;
    int numBins;

  WaveSampleProvider *wsp;
  AVPlayer *player;
  NSString *infoString;

    id<AudioVisualizerViewControllerDelegate> __unsafe_unretained delegate;

    CGFloat navBarSize;
    CGFloat statusBarSize;
    CGFloat navAndStatusBarSize;
}

@end

@implementation AudioVisualizerViewController

- (id) initWithAudioURL:(NSURL *)u delegate:(id<AudioVisualizerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        audioURL = u;
        delegate = d;

        numBins = 512;
        sampleRate = 44100.0f;
        sampleLength = 0;
        playProgress = 0.0;
        endTime = 1.0;

        wsp = [[WaveSampleProvider alloc] initWithURL:audioURL delegate:self];
        [wsp createSampleData];
    }
    return self;
}

- (void) orientationHack:(UIInterfaceOrientation)orientation
{
    //this is a giant hack that causes the current view controller to re-evaluate the orientation its in.
    //change if a better way is found for forcing the orientation to initially be in landscape
    /*
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = [window.subviews objectAtIndex:0];
    [view removeFromSuperview];
    [window addSubview:view];
    */

    /*
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    ARISViewController *root = (ARISViewController *)window.rootViewController;
    window.rootViewController = nil;
    window.rootViewController = root;
    [ARISViewController attemptRotationToDeviceOrientation];
     */

    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), orientation);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    CGSize ss = [UIScreen mainScreen].bounds.size;
    CGSize ms = self.view.bounds.size;

    //32 is the nav bar in landscape, 20 is the status bar
    navBarSize = 32;
    statusBarSize = 20;
    navAndStatusBarSize = navBarSize + statusBarSize;
    CGFloat sliderWidth = 35;

    //height and width are switch around because we are in landscape mode now
    freqControl = [[FreqHistogramControl alloc] initWithFrame:CGRectMake(0, navAndStatusBarSize, ms.height, ms.width - navAndStatusBarSize) delegate:self];
    wfControl   = [[WaveformControl      alloc] initWithFrame:CGRectMake(0, navAndStatusBarSize, ms.height, ms.width - navAndStatusBarSize) delegate:self];
    playHead    = [[Playhead             alloc] initWithFrame:CGRectMake(0, navAndStatusBarSize, ms.height, ms.width - navAndStatusBarSize) delegate:self];
    [freqControl setHidden:YES];
    [self.view addSubview:freqControl];
    [self.view addSubview:wfControl];
    [self.view addSubview:playHead];


    //must subtract an addition nav bar here because of the toolbar at the bottom
    leftSlider  = [[AudioSlider alloc] initWithFrame:CGRectMake(        -(sliderWidth/2), navAndStatusBarSize, sliderWidth, ms.width - navAndStatusBarSize - navBarSize)];
    rightSlider = [[AudioSlider alloc] initWithFrame:CGRectMake(ms.height-(sliderWidth / 2), navAndStatusBarSize, sliderWidth, ms.width - navAndStatusBarSize - navBarSize)];
    [leftSlider  addTarget:self action:@selector(draggedOut:withEvent:) forControlEvents:(UIControlEventTouchDragOutside | UIControlEventTouchDragInside)];
    [rightSlider addTarget:self action:@selector(draggedOut:withEvent:) forControlEvents:(UIControlEventTouchDragOutside | UIControlEventTouchDragInside)];
    leftTint  = [[UIView alloc] initWithFrame:CGRectMake(                   0, navAndStatusBarSize, leftSlider.center.x, ms.width- navAndStatusBarSize - navBarSize)];
    rightTint = [[UIView alloc] initWithFrame:CGRectMake(rightSlider.center.x, navAndStatusBarSize,            ms.width, ms.width - navAndStatusBarSize - navBarSize)];
    leftTint.backgroundColor  = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    rightTint.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    leftTint.opaque  = NO;
    rightTint.opaque = NO;
    [self.view addSubview:leftTint];
    [self.view addSubview:rightTint];
    [self.view addSubview:leftSlider];
    [self.view addSubview:rightSlider];


    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, ms.width-navBarSize, ms.height, navBarSize)];

    playButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    stopButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    swapButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];

    [playButton  setImage:[UIImage imageNamed:@"dark_play.png"]  forState:UIControlStateNormal];
    [pauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [stopButton  setImage:[UIImage imageNamed:@"stop.png"]  forState:UIControlStateNormal];
    [swapButton  setImage:[UIImage imageNamed:@"shuffle.png"]      forState:UIControlStateNormal];

    [playButton  addTarget:self action:@selector(play)     forControlEvents:UIControlEventTouchUpInside];
    [pauseButton addTarget:self action:@selector(pause)    forControlEvents:UIControlEventTouchUpInside];
    [stopButton  addTarget:self action:@selector(stop)     forControlEvents:UIControlEventTouchUpInside];
    [swapButton  addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];

    playPauseBarButton = [[UIBarButtonItem alloc] initWithCustomView:playButton];
    stopBarButton      = [[UIBarButtonItem alloc] initWithCustomView:stopButton];
    swapBarButton      = [[UIBarButtonItem alloc] initWithCustomView:swapButton];

    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 25)];
    [timeLabel setText:@""];
    [timeLabel setTextColor:[UIColor blackColor]];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    timeBarButton = [[UIBarButtonItem alloc] initWithCustomView:timeLabel];

    freqLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 25)];
    [freqLabel setText:@""];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor blackColor]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    freqBarButton = [[UIBarButtonItem alloc] initWithCustomView:freqLabel];

    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = (ss.height - 352)/4;

    NSArray *toolbarButtons = [NSArray arrayWithObjects:playPauseBarButton, stopBarButton, fixedSpace, timeBarButton, fixedSpace, freqBarButton, fixedSpace, swapBarButton, nil];
    [toolbar setItems:toolbarButtons animated:NO];
    [self.view addSubview:toolbar];

    UIBarButtonItem *rightNavBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(saveAudio)];
    self.navigationItem.rightBarButtonItem = rightNavBarButton;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //disable swipe to go back and the ph reveal controller
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.navigationController.revealController.recognizesPanningOnFrontView = NO;
}

- (void) viewDidLoad
{
    [self orientationHack:UIInterfaceOrientationLandscapeRight];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self orientationHack:UIInterfaceOrientationPortrait];
    //enable the pk reveal controller and the swipe to go back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.navigationController.revealController.recognizesPanningOnFrontView = YES;
}


- (void) draggedOut:(UIControl *)c withEvent:(UIEvent *)ev
{
    [self stop];
    CGPoint point = [[[ev allTouches] anyObject] locationInView:self.view];

    if(point.x > 0 && point.x < self.view.bounds.size.width)
    {
        if([c isEqual:leftSlider])
        {
            if(rightSlider.center.x - point.x > SLIDER_BUFFER) leftSlider.center = CGPointMake(point.x, c.center.y);
            else                                               leftSlider.center = CGPointMake(rightSlider.center.x - SLIDER_BUFFER, c.center.y);

            [self setPlayHeadToLeftSlider];
            leftTint.frame = CGRectMake(0, navAndStatusBarSize, leftSlider.center.x, self.view.bounds.size.height - navAndStatusBarSize - navBarSize);
        }
        else
        {
            if(leftSlider.center.x - point.x < -SLIDER_BUFFER) rightSlider.center = CGPointMake(point.x, c.center.y);
            else                                               rightSlider.center = CGPointMake(leftSlider.center.x + SLIDER_BUFFER, c.center.y);

            [self setPlayHeadToLeftSlider];
            rightTint.frame = CGRectMake(rightSlider.center.x, navAndStatusBarSize, self.view.bounds.size.width, self.view.bounds.size.height - navAndStatusBarSize - navBarSize);
            CGFloat percentScreen = rightSlider.center.x / self.view.bounds.size.width;
            endTime = percentScreen;
        }
    }
}

- (void) setPlayHeadToLeftSlider
{
    CGFloat x = leftSlider.center.x - self.view.bounds.origin.x;
    float sel = x / self.view.bounds.size.width;
    duration = CMTimeGetSeconds(player.currentItem.duration);
    float timeSelected = duration * sel;
    CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
    [player seekToTime:tm];
    [self loadAudio];
}

- (void) updateTimeString
{
    duration = CMTimeGetSeconds(player.currentItem.duration);
    Float64 currentTime = CMTimeGetSeconds(player.currentTime);
    int dmin = duration / 60;
    int dsec = duration - (dmin * 60);
    int cmin = currentTime / 60;
    int csec = currentTime - (cmin * 60);
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",cmin,csec,dmin,dsec];
    if(duration > 0) playProgress = currentTime/duration;
    else             playProgress = 0;
}

- (void) start
{
  if(wsp.status != LOADED) return;

    player = [[AVPlayer alloc] initWithURL:wsp.audioURL];
    [self addTimeObserver];
}

- (void) play
{
    [player play];
    [playPauseBarButton setCustomView:pauseButton];
    [self updateTimeString];
}

- (void) pause
{
    [player pause];
    [playPauseBarButton setCustomView:playButton];
}

- (void) stop
{
    [self pause];
    [player removeTimeObserver:timeObserver];
    [self addTimeObserver];
    [self setPlayHeadToLeftSlider];
}

- (void) addTimeObserver
{
    CMTime tm = CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC);
    __weak id weakSelf = self;
    __weak id weakPlayHead = playHead;
    __weak id weakWf = wfControl;
    timeObserver = [player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
    {
        [weakSelf updateTimeString];
        if(![weakPlayHead isHidden])                            [weakPlayHead setNeedsDisplay];
        if([weakWf isHidden])                                   [weakSelf     loadAudio];
        if([weakSelf getPlayProgress] >= [weakSelf getEndTime]) [weakSelf     stop];
    }];
}

- (void) setSampleData:(float *)sd length:(int)length
{
  sampleLength = 0;

  length += 2;
  CGPoint *tempData = (CGPoint *)calloc(sizeof(CGPoint),length);
  tempData[0] = CGPointMake(0.0,0.0);
  tempData[length-1] = CGPointMake(length-1,0.0);
  for(int i = 1; i < length-1;i++)
    tempData[i] = CGPointMake(i, sd[i]);

  CGPoint *oldData = sampleData;

  sampleData = tempData;
  sampleLength = length;

  if(oldData != nil) free(oldData);
  free(sd);

  [wfControl setNeedsDisplay];
    [freqControl setNeedsDisplay];
}

- (CGPoint *) getSampleData            { return sampleData; }
- (long) getSampleLength               { return sampleLength; }
- (float) getPlayProgress              { return playProgress; }
- (float) getEndTime                   { return endTime; }
- (void) setAudioLength:(float)seconds { lengthInSeconds = seconds; }

- (void) sampleProcessed:(WaveSampleProvider *)provider
{
  if(wsp.status == LOADED)
    {
    long sdl = 0;
    //float *sd = [wsp dataForResolution:[self waveRect].size.width lenght:&sdl];
    float *sd = [wsp dataForResolution:8000 lenght:&sdl];
    [self setSampleData:sd length:(int)sdl];
    long dmin = wsp.minute;
    long dsec = wsp.sec;
        timeLabel.text = [NSString stringWithFormat:@"--:--/%02ld:%02ld",dmin,dsec];
    [self start];
  }
}

- (void) playheadControl:(Playhead *)playhead wasTouched:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
  CGPoint local_point = [touch locationInView:self.view];
  if(CGRectContainsPoint(self.view.bounds,local_point) && player != nil)
    {
        CGFloat x = local_point.x - self.view.bounds.origin.x;
        float sel = x / self.view.bounds.size.width;
        duration = CMTimeGetSeconds(player.currentItem.duration);
        float timeSelected = duration * sel;
        CMTime tm = CMTimeMakeWithSeconds(timeSelected, NSEC_PER_SEC);
        [player seekToTime:tm];
        [self loadAudio];
  }
}

- (void) freqHistogramControl:(WaveformControl *)waveform wasTouched:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint local_point = [touch locationInView:freqControl];
    float binWidth = freqControl.bounds.size.width / (numBins/2);
    float bin = local_point.x / binWidth;

    if(CGRectContainsPoint(freqControl.bounds,local_point))
        freqControl.currentFreqX = local_point.x;

    [freqControl setNeedsDisplay];

    [freqLabel setText:[NSString stringWithFormat:@"%.2f Hz", ((bin * sampleRate)/numBins)]];
    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor blackColor]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
}

- (void) saveAudio
{
    [player pause];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd_MM_yyyy_HH_mm_ss"];
    NSURL *tmpOutFile = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@_audio_trimmed.m4a", [outputFormatter stringFromDate:[NSDate date]]]]];

    AVAsset *asset = [AVAsset assetWithURL:audioURL];

    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];

    duration = CMTimeGetSeconds(player.currentItem.duration);

    float vocalStartMarker  = (leftSlider.center.x  / self.view.bounds.size.width) * duration;
    float vocalEndMarker    = (rightSlider.center.x / self.view.bounds.size.width) * duration;

    CMTime startTime = CMTimeMake(vocalStartMarker , 1);
    CMTime stopTime = CMTimeMake(vocalEndMarker , 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);

    exportSession.outputURL = tmpOutFile;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;

    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if(AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [delegate fileWasTrimmed:tmpOutFile];
                 [[NSFileManager defaultManager] removeItemAtURL:audioURL error: nil];
             });
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"SaveErrorTitleKey", nil) message:NSLocalizedString(@"SaveErrorKey", nil)];
         }
     }];
}


- (void) flipView
{

    [wfControl setHidden:![wfControl isHidden]];
    [freqControl setHidden:![freqControl isHidden]];

    if([wfControl isHidden])
    {
        float binWidth = freqControl.bounds.size.width / (numBins/2);
        float bin = freqControl.currentFreqX / binWidth;
        [freqLabel setText:[NSString stringWithFormat:@"%.2f Hz", ((bin * sampleRate)/numBins)]];
    }
    else
    {
        [freqLabel setText:@""];
    }


    [freqLabel setBackgroundColor:[UIColor clearColor]];
    [freqLabel setTextColor:[UIColor blackColor]];
    [freqLabel setTextAlignment:NSTextAlignmentCenter];
    [leftSlider setHidden:![leftSlider isHidden]];
    [rightSlider setHidden:![rightSlider isHidden]];
    [leftTint setHidden:![leftTint isHidden]];
    [rightTint setHidden:![rightTint isHidden]];
    [playHead setHidden:![playHead isHidden]];
}

- (void) loadAudio
{
    ExtAudioFileRef extAFRef;
  if(ExtAudioFileOpenURL((__bridge CFURLRef)audioURL, &extAFRef) != noErr)
    {
        _ARIS_LOG_(@"Cannot open audio file");
        return;
    }

    extAFNumChannels = 2;

    OSStatus err;
    AudioStreamBasicDescription fileFormat;
    UInt32 propSize = sizeof(fileFormat);
    memset(&fileFormat, 0, sizeof(AudioStreamBasicDescription));

    err = ExtAudioFileGetProperty(extAFRef, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
  if(err != noErr) _ARIS_LOG_(@"Cannot get audio file properties");

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
    _ARIS_LOG_(@"Couldn't convert audio file to PCM format");
    return;
  }

    err = ExtAudioFileSeek(extAFRef, startingSample);
    if(err != noErr) {
    _ARIS_LOG_(@"Error in seeking in file");
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
    if(err != noErr)
    {
    _ARIS_LOG_(@"Error in reading the file");
    return;
  }
    freqControl.fourierData = [self computeFFTForData:returnData forSampleSize:1024];
    [freqControl setNeedsDisplay];
}

- (float *) computeFFTForData:(float *)data forSampleSize:(int)bufferFrames
{
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

    float *mag   = (float *)malloc(sizeof(float) * bufferFrames/2);
    float *phase = (float *)malloc(sizeof(float) * bufferFrames/2);
    float *magDB = (float *)malloc(sizeof(float) * bufferFrames/2);

    vDSP_zvabs(&out, 1, mag, 1, bufferFrames/2);
    vDSP_zvphas(&out, 1, phase, 1, bufferFrames/2);

    for(int k = 1; k < bufferFrames/2; k++)
    {
        float magnitudeDB = 10 * log10(out.realp[k] * out.realp[k] + (out.imagp[k] * out.imagp[k]));
        magDB[k] = magnitudeDB;
        if(magDB[k] > freqControl.largestMag)
            freqControl.largestMag = magDB[k];
    }

    return magDB;
}


- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
