//
//  AudioRecorderViewController.m
//  AudioDemo
//
//  Edited by Nick Heindl on 07/8/13.
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.


#import "AudioRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AppModel.h"
#import "AudioMeter.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "ARISAlertHandler.h"
#import "AudioVisualizerViewController.h"

@interface AudioRecorderViewController() <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AudioRecorderModeType mode;
	AudioMeter *meter;
    NSTimer *meterUpdateTimer;

    AVAudioSession *session;
	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
    NSURL *soundFileURL;
    NSString *soundFileString;
    BOOL isTrimmedFile;
    
    IBOutlet UIButton *recordStopOrPlayButton;
	IBOutlet UIButton *uploadButton;
	IBOutlet UIButton *discardButton;
    IBOutlet UIButton *editButton;
    
    id<AudioRecorderViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, assign) AudioRecorderModeType mode;
@property (nonatomic, strong) AudioMeter *meter;
@property (nonatomic, strong) AVAudioRecorder *soundRecorder;
@property (nonatomic, strong) AVAudioPlayer *soundPlayer;
@property (nonatomic, strong) NSURL *soundFileURL;
@property (nonatomic, strong) NSString *soundFileString;
@property (nonatomic, strong) NSTimer *meterUpdateTimer;

@property (nonatomic, strong) IBOutlet UIButton *recordStopOrPlayButton;
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UIButton *discardButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;

@end

@implementation AudioRecorderViewController

@synthesize mode;
@synthesize meter;
@synthesize soundRecorder;
@synthesize soundPlayer;
@synthesize soundFileURL;
@synthesize soundFileString;
@synthesize meterUpdateTimer;

@synthesize recordStopOrPlayButton;
@synthesize uploadButton;
@synthesize discardButton;
@synthesize editButton;

- (id) initWithDelegate:(id<AudioRecorderViewControllerDelegate>)d
{
    if((self = [super initWithNibName:@"AudioRecorderViewController" bundle:nil]))
    {
        delegate = d;
        self.title = NSLocalizedString(@"AudioRecorderTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"microphoneTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"microphoneTabBarSelected"]];
        
        session = [AVAudioSession sharedInstance];
        
        isTrimmedFile = NO;
        
        NSString *tempDir = NSTemporaryDirectory ();
        self.soundFileString = [tempDir stringByAppendingString:[NSString stringWithFormat:@"%@",[self getUniqueId]]];
        
        self.soundFileURL = [[NSURL alloc] initFileURLWithPath:[self.soundFileString stringByAppendingString:@".m4a"]];
                
        [session setDelegate:self];
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

- (void) viewDidAppear:(BOOL)animated
{
    if(isTrimmedFile)
    {
        NSString *soundFileStringEncoded = [self.soundFileString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //Add file://localhost to the path here because it goes away when not inited.
        self.soundFileURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@trimmed.m4a",soundFileStringEncoded]];
        [self uploadAudio];
    }
}

- (void) backButtonTouchAction
{
    [delegate audioRecorderViewControllerCancelled];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) dealloc
{
    [session setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void) setMode:(AudioRecorderModeType)m
{
    mode = m;
    
	[uploadButton setTitle:NSLocalizedString(@"SaveKey", @"") forState:UIControlStateNormal];

	[discardButton setTitle:NSLocalizedString(@"DiscardKey", @"") forState:UIControlStateNormal];
    
    [editButton setTitle:NSLocalizedString(@"EditKey", @"") forState:UIControlStateNormal];
	
	switch(mode)
    {
		case kAudioRecorderStarting:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"BeginRecordingKey", @"") forState:UIControlStateNormal];
			uploadButton.hidden  = YES;
			discardButton.hidden = YES;
            editButton.hidden = YES;
			break;
		case kAudioRecorderRecording:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"StopRecordingKey", @"") forState:UIControlStateNormal];
			uploadButton.hidden  = YES;
			discardButton.hidden = YES;
            editButton.hidden = YES;
			break;
		case kAudioRecorderRecordingComplete:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"PlayKey", @"") forState:UIControlStateNormal];
			uploadButton.hidden  = NO;
			discardButton.hidden = NO;
            editButton.hidden = NO;
			break;
		case kAudioRecorderPlaying:
			[recordStopOrPlayButton setTitle:NSLocalizedString(@"StopKey", @"") forState:UIControlStateNormal];
			uploadButton.hidden  = YES;
			discardButton.hidden = YES;
            editButton.hidden = YES;
			break;
        case kAudioRecorderNoteMode:
            [recordStopOrPlayButton setTitle:NSLocalizedString(@"StopRecordingKey", @"") forState:UIControlStateNormal];
            uploadButton.hidden  = YES;
            discardButton.hidden = YES;
            editButton.hidden = YES;
            mode = kAudioRecorderRecording;
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
	[session setActive:NO error:nil];
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
            
        //Set up the recorder's properties.
		case kAudioRecorderStarting:
        {
			[session setCategory:AVAudioSessionCategoryRecord error: nil];
			NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
											[NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
											[NSNumber numberWithInt:44100.0],AVSampleRateKey,
											[NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
											[NSNumber numberWithInt: AVAudioQualityMin],AVSampleRateConverterAudioQualityKey,
											nil];
			self.soundRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:nil];
			self.soundRecorder.delegate = self;
			[self.soundRecorder setMeteringEnabled:YES];
			[self.soundRecorder prepareToRecord];
			if(![session inputIsAvailable])
            {
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"NoAudioHardwareAvailableTitleKey", @"") message:NSLocalizedString(@"NoAudioHardwareAvailableMessageKey", @"")];
				return;
			}
            [session setActive:YES error:nil];
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
			[session setCategory: AVAudioSessionCategoryPlayback error: nil];
			[session setActive: YES error: nil];
			if (self.soundPlayer == nil) {
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
            [self.soundRecorder stop];
            [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
			[session setCategory:AVAudioSessionCategoryPlayback error: nil];
			self.soundRecorder = nil;
            [self setMode:kAudioRecorderRecordingComplete];
            break;
		default:
			break;
	}
}

- (IBAction) uploadButtonAction:(id)sender
{
    [self uploadAudio];
}

- (IBAction) discardButtonAction:(id)sender
{
	self.soundPlayer = nil;
	[self setMode:kAudioRecorderStarting];
}

- (IBAction) editButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileWasTrimmed)
                                                 name:@"AudioWasTrimmedNotification"
                                               object:nil];
    
    //self.soundPlayer = nil;//Not sure if need - still need to test.
    AudioVisualizerViewController *audioVC = [[AudioVisualizerViewController alloc] initWithNibName:@"AudioVisualizerViewController" bundle:nil];
    audioVC.inputOutputPathURL = self.soundFileURL;
    audioVC.intermediatePathString = self.soundFileString;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    [self.navigationController pushViewController:audioVC animated:YES];
    
}

- (void) uploadAudio{
    self.soundRecorder = nil;
    [delegate audioChosenWith:self.soundFileURL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) fileWasTrimmed{
    NSLog(@"File was trimmed.");
    isTrimmedFile = YES;
}

- (void) viewDidUnload {
    [self setEditButton:nil];
    [super viewDidUnload];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
