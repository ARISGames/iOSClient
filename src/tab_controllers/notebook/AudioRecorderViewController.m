//
//  AudioRecorderViewController.m
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AppModel.h"
#import "AudioMeter.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "ARISAlertHandler.h"

@interface AudioRecorderViewController() <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AudioRecorderModeType mode;
	AudioMeter *meter;
    NSTimer *meterUpdateTimer;

	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
    NSURL *soundFileURL;
    
    IBOutlet UIButton *recordStopOrPlayButton;
	IBOutlet UIButton *uploadButton;
	IBOutlet UIButton *discardButton;
    
    id<AudioRecorderViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, assign) AudioRecorderModeType mode;
@property (nonatomic, strong) AudioMeter *meter;
@property (nonatomic, strong) AVAudioRecorder *soundRecorder;
@property (nonatomic, strong) AVAudioPlayer *soundPlayer;
@property (nonatomic, strong) NSURL *soundFileURL;
@property (nonatomic, strong) NSTimer *meterUpdateTimer;

@property (nonatomic, strong) IBOutlet UIButton *recordStopOrPlayButton;
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UIButton *discardButton;

@end

@implementation AudioRecorderViewController

@synthesize mode;
@synthesize meter;
@synthesize soundRecorder;
@synthesize soundPlayer;
@synthesize soundFileURL;
@synthesize meterUpdateTimer;

@synthesize recordStopOrPlayButton;
@synthesize uploadButton;
@synthesize discardButton;

- (id) initWithDelegate:(id<AudioRecorderViewControllerDelegate>)d
{
    if((self = [super initWithNibName:@"AudioRecorderViewController" bundle:nil]))
    {
        delegate = d;
        self.title = NSLocalizedString(@"AudioRecorderTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"microphone.png"];
        
        NSString *tempDir = NSTemporaryDirectory ();
        self.soundFileURL = [[NSURL alloc] initFileURLWithPath:[tempDir stringByAppendingString:[NSString stringWithFormat:@"%@.caf",[self getUniqueId]]]];
        
        [[AVAudioSession sharedInstance] setDelegate:self];
    }
    return self;
}

- (NSString *) getUniqueId
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchAction)];
    self.meter = [[AudioMeter alloc] initWithFrame:CGRectMake(0, 0, 320, 360)];
	self.meter.alpha = 0.0;
	[self.view addSubview:self.meter];
	[self.view sendSubviewToBack:self.meter];

    [self setMode:kAudioRecorderStarting];
}

- (void) backButtonTouchAction
{
    [delegate audioRecorderViewControllerCancelled];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) dealloc
{
    [[AVAudioSession sharedInstance] setDelegate:nil];
}

- (void) setMode:(AudioRecorderModeType)m
{
    mode = m;
    
	[uploadButton setTitle:NSLocalizedString(@"SaveKey", @"") forState:UIControlStateNormal];
	[uploadButton setTitle:NSLocalizedString(@"SaveKey", @"") forState:UIControlStateHighlighted];

	[discardButton setTitle:NSLocalizedString(@"DiscardKey", @"") forState:UIControlStateNormal];
	[discardButton setTitle:NSLocalizedString(@"DiscardKey", @"") forState:UIControlStateHighlighted];
	
	switch(mode)
    {
		case kAudioRecorderStarting:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"BeginRecordingKey", @"") forState:UIControlStateNormal];
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"BeginRecordingKey", @"") forState:UIControlStateHighlighted];
			uploadButton.hidden  = YES;
			discardButton.hidden = YES;
			break;
		case kAudioRecorderRecording:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"StopRecordingKey", @"") forState:UIControlStateNormal];
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"StopRecordingKey", @"") forState:UIControlStateHighlighted];
			uploadButton.hidden  = YES;
			discardButton.hidden = YES;
			break;
		case kAudioRecorderRecordingComplete:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"PlayKey", @"") forState:UIControlStateNormal];
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"PlayKey", @"") forState:UIControlStateHighlighted];
			uploadButton.hidden  = NO;
			discardButton.hidden = NO;
			break;
		case kAudioRecorderPlaying:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"StopKey", @"") forState:UIControlStateNormal];
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"StopKey", @"") forState:UIControlStateHighlighted];
			uploadButton.hidden  = YES;
			discardButton.hidden = YES;
			break;
        case kAudioRecorderNoteMode:
            [recordStopOrPlayButton setTitle:NSLocalizedString(@"PlayKey", @"") forState:UIControlStateNormal];
            [recordStopOrPlayButton setTitle:NSLocalizedString(@"PlayKey", @"") forState:UIControlStateHighlighted];
            uploadButton.hidden  = YES;
            discardButton.hidden = YES;
            mode = kAudioRecorderRecordingComplete;
            break;
		default:
			break;
	}
}

- (void)updateMeter
{
	[self.soundRecorder updateMeters];
	float levelInDb = [self.soundRecorder averagePowerForChannel:0];
	levelInDb = levelInDb + 160;
	
	//Level will always be between 0 and 160 now
	//Usually it will sit around 100 in quiet so we need to correct
	levelInDb = MAX(levelInDb - 100,0);
	float levelInZeroToOne = levelInDb / 60;
    
	[self.meter updateLevel:levelInZeroToOne];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	[self.meterUpdateTimer invalidate];
	[self.meter updateLevel:0];
	self.meter.alpha = 0.0; 
	
	[self setMode:kAudioRecorderRecordingComplete];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[[AVAudioSession sharedInstance] setActive:NO error:nil];
	self.soundPlayer = nil;
	[self setMode:kAudioRecorderRecordingComplete];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	NSLog(@"AudioRecorder: Playback Error");
}

- (IBAction) recordStopOrPlayButtonAction:(id)sender
{	
	switch(mode)
    {
		case kAudioRecorderStarting:
        {
			[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error: nil];
			NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
											[NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
											[NSNumber numberWithInt:16000.0],AVSampleRateKey,
											[NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
											[NSNumber numberWithInt: AVAudioQualityMin],AVSampleRateConverterAudioQualityKey,
											nil];
			self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:nil];
			self.soundRecorder.delegate = self;
			[self.soundRecorder setMeteringEnabled:YES];
			[self.soundRecorder prepareToRecord];
			if(![[AVAudioSession sharedInstance] inputIsAvailable])
            {
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoAudioHardwareAvailableTitleKey", @"") message:NSLocalizedString(@"NoAudioHardwareAvailableMessageKey", @"")];
				return;
			}
			[self.soundRecorder record];
			self.meter.alpha = 1.0;
			self.meterUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
																	 target:self
																   selector:@selector(updateMeter)
																   userInfo:nil
																	repeats:YES];
			[self setMode:kAudioRecorderNoteMode];
        }
            break;
		case kAudioRecorderPlaying:
			[self.soundPlayer stop];
            [self setMode:kAudioRecorderRecordingComplete];
            break;
		case kAudioRecorderRecordingComplete:
			[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
			[[AVAudioSession sharedInstance] setActive: YES error: nil];
			if (nil == self.soundPlayer) {
				NSError *error;
				AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error: &error];
				self.soundPlayer = newPlayer;
				[self.soundPlayer prepareToPlay];
				[self.soundPlayer setDelegate: self];
			}
            [self setMode:kAudioRecorderPlaying];
			[self.soundPlayer play];
            break;
		case kAudioRecorderRecording:
			[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
			[self.soundRecorder stop];
			self.soundRecorder = nil;
            [self setMode:kAudioRecorderRecordingComplete];
            break;
		default:
			break;
	}
}

- (IBAction) uploadButtonAction:(id)sender
{
	self.soundRecorder = nil;
    [delegate audioChosenWith:self.soundFileURL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) discardButtonAction:(id)sender
{
	self.soundPlayer = nil;
	[self setMode:kAudioRecorderStarting];
}


@end
