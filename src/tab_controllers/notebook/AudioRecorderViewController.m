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

@interface AudioRecorderViewController() <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
	AudioMeter *meter;
	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
	NSData *audioData;
	IBOutlet UIButton *recordStopOrPlayButton;
	IBOutlet UIButton *uploadButton;
	IBOutlet UIButton *discardButton;
	BOOL recording;
	BOOL playing;
	NSTimer *meterUpdateTimer;
	id backView;
    id parentDelegate;
    id editView;
    
    id<AudioRecorderViewControllerDelegate> __unsafe_unretained delegate;
}

@property(nonatomic) AudioMeter *meter;
@property(nonatomic) NSData *audioData;
@property(nonatomic) AVAudioRecorder *soundRecorder;
@property(nonatomic) AVAudioPlayer *soundPlayer;
@property(nonatomic) NSTimer *meterUpdateTimer;
@property(nonatomic) id backView;
@property(nonatomic) id parentDelegate;
@property(nonatomic) id editView;

- (NSString *)getUniqueId;

@end

@implementation AudioRecorderViewController

@synthesize soundRecorder;
@synthesize soundPlayer;
@synthesize meter;
@synthesize meterUpdateTimer;
@synthesize audioData;
@synthesize backView;
@synthesize parentDelegate;
@synthesize editView;

- (id) initWithDelegate:(id<AudioRecorderViewControllerDelegate>)d
{
    if((self = [super initWithNibName:@"AudioRecorderViewController" bundle:nil]))
    {
        delegate = d;
        self.title = NSLocalizedString(@"AudioRecorderTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"microphone.png"];
        
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
	[self.view addSubview:meter];
	[self.view sendSubviewToBack:meter];

    [self updateButtonsForMode:kAudioRecorderStarting];
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

- (void) updateButtonsForMode:(AudioRecorderModeType)mode
{
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
	
	[self updateButtonsForMode:kAudioRecorderRecordingComplete];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	NSLog(@"audioPlayerDidFinishPlaying");
	[[AVAudioSession sharedInstance] setActive: NO error: nil];
    
	soundPlayer = nil;
	
	[self updateButtonsForMode:kAudioRecorderRecordingComplete];
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
			NSLog(@"AudioRecorder: Record/Play/Stop Button selected");
			
			[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: nil];
			
			NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
											[NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
											[NSNumber numberWithInt:16000.0],AVSampleRateKey,
											[NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
											[NSNumber numberWithInt: AVAudioQualityMin],AVSampleRateConverterAudioQualityKey,
											nil];
			
			AVAudioRecorder *newRecorder = [[AVAudioRecorder alloc] initWithURL: soundFileURL settings: recordSettings error: nil];
			self.soundRecorder = newRecorder;
			
			soundRecorder.delegate = self;
			[soundRecorder setMeteringEnabled:YES];
			[soundRecorder prepareToRecord];
			
			
			BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
			if (! audioHWAvailable) {
				UIAlertView *cantRecordAlert =
				[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"NoAudioHardwareAvailableTitleKey", @"")
										   message: NSLocalizedString(@"NoAudioHardwareAvailableMessageKey", @"")
										  delegate: nil
								 cancelButtonTitle: NSLocalizedString(@"OkKey",@"")
								 otherButtonTitles:nil];
				[cantRecordAlert show];
				return;
			}
			
			[soundRecorder record];
			
			self.meter.alpha = 1.0;
			self.meterUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
																	 target:self
																   selector:@selector(updateMeter)
																   userInfo:nil
																	repeats:YES];
			NSLog(@"Recording.");
			mode = kAudioRecorderRecording;
			[self updateButtonsForCurrentMode];
            break;
			
		case kAudioRecorderPlaying:
			[self.soundPlayer stop];
            if(!self.previewMode)
                mode = kAudioRecorderRecordingComplete;
            else
                mode = kAudioRecorderNoteMode;
            
			[self updateButtonsForCurrentMode];
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
			
			mode = kAudioRecorderPlaying;
			[self updateButtonsForCurrentMode];
			
			[self.soundPlayer play];
            break;
			
		case kAudioRecorderRecording:
			[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
			
			[soundRecorder stop];
			self.soundRecorder = nil;
			mode = kAudioRecorderRecordingComplete;
			[self updateButtonsForCurrentMode];
            break;
			
		default:
			break;
	}
}

- (IBAction) uploadButtonAction: (id) sender{
	self.audioData = [NSData dataWithContentsOfURL:soundFileURL];
	self.soundRecorder = nil;
	
	//Do server call here
    
    if([self.parentDelegate isKindOfClass:[NoteCommentViewController class]]) {
        [self.parentDelegate addedAudio];
        
    }
    if([self.editView isKindOfClass:[NoteEditorViewController class]]) {
        [self.editView setNoteValid:YES];
        [self.editView setNoteChanged:YES];
    }
    
    [[[AppModel sharedAppModel]uploadManager] uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"AUDIO" withFileURL:self.soundFileURL];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction) discardButtonAction: (id) sender{
	soundPlayer = nil;
	mode = kAudioRecorderStarting;
	[self updateButtonsForCurrentMode];
}


@end
