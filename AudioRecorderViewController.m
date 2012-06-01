//
//  AudioRecorderViewController.m
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "GPSViewController.h"
#import "NoteDetailsViewController.h"
#import "NoteCommentViewController.h"
#import "NoteEditorViewController.h"

@implementation AudioRecorderViewController
@synthesize soundFileURL;
@synthesize soundRecorder;
@synthesize soundPlayer;
@synthesize meter;
@synthesize meterUpdateTimer;
@synthesize audioData, backView,parentDelegate, noteId,previewMode,editView;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = NSLocalizedString(@"AudioRecorderTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"microphone.png"];
    }
    return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


- (NSString *)getUniqueId
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"")
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target:self 
                                                                  action:@selector(backButtonTouchAction)];

	self.navigationItem.leftBarButtonItem = backButton;
		meter = [[AudioMeter alloc]initWithFrame:CGRectMake(0, 0, 320, 360)];
	meter.alpha = 0.0;
	[self.view addSubview:meter];
	[self.view sendSubviewToBack:meter];
	

	NSString *tempDir = NSTemporaryDirectory ();
    NSString *soundFilePath =[tempDir stringByAppendingString: [NSString stringWithFormat:@"%@.caf",[self getUniqueId]]];
	
    if(!previewMode){
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    self.soundFileURL = newURL;
    mode = kAudioRecorderStarting; 
       
    [[AVAudioSession sharedInstance] setDelegate: self];
	}
    else mode = kAudioRecorderNoteMode;
	
	 [self updateButtonsForCurrentMode];

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)backButtonTouchAction{
    if([backView isKindOfClass:[NotebookViewController class]]){
        [[AppServices sharedAppServices]deleteNoteWithNoteId:self.noteId];
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.noteId]];   
    }
    [self.navigationController popToViewController:self.backView animated:NO];   
}
- (void)dealloc {
    [[AVAudioSession sharedInstance] setDelegate: nil];
   /* if(backView)
    [backView release];
    if(editView)
    [editView release];
    if(parentDelegate)
    [parentDelegate release];*/
    
}

- (void)updateButtonsForCurrentMode{
	[uploadButton setTitle: @"Save" forState: UIControlStateNormal];
	[uploadButton setTitle: @"Save" forState: UIControlStateHighlighted];			

	[discardButton setTitle: NSLocalizedString(@"DiscardKey", @"") forState: UIControlStateNormal];
	[discardButton setTitle: NSLocalizedString(@"DiscardKey", @"") forState: UIControlStateHighlighted];			

	
	
	switch (mode) {
		case kAudioRecorderStarting:
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"BeginRecordingKey", @"") forState: UIControlStateNormal];
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"BeginRecordingKey", @"") forState: UIControlStateHighlighted];			
			uploadButton.hidden = YES;
			discardButton.hidden = YES;
			break;
		case kAudioRecorderRecording:
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"StopRecordingKey", @"") forState: UIControlStateNormal];
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"StopRecordingKey", @"") forState: UIControlStateHighlighted];			
			uploadButton.hidden = YES;
			discardButton.hidden = YES;
			break;
		case kAudioRecorderRecordingComplete:
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"PlayKey", @"") forState: UIControlStateNormal];
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"PlayKey", @"") forState: UIControlStateHighlighted];			
			uploadButton.hidden = NO;
			discardButton.hidden = NO;
			break;
		case kAudioRecorderPlaying:
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"StopKey", @"") forState: UIControlStateNormal];
			[recordStopOrPlayButton setTitle: NSLocalizedString(@"StopKey", @"") forState: UIControlStateHighlighted];			
			uploadButton.hidden = YES;
			discardButton.hidden = YES;
			break;
        case kAudioRecorderNoteMode:
            [recordStopOrPlayButton setTitle: NSLocalizedString(@"PlayKey", @"") forState: UIControlStateNormal];
            [recordStopOrPlayButton setTitle: NSLocalizedString(@"PlayKey", @"") forState: UIControlStateHighlighted];			
            uploadButton.hidden = YES;
            discardButton.hidden = YES;
            mode = kAudioRecorderRecordingComplete;

            break;
		default:

			break;
	}
    }

- (IBAction) recordStopOrPlayButtonAction: (id) sender{
	
	NSLog(@"AudioRecorder: Record/Play/Stop Button selected");
	
	switch (mode) {
		case kAudioRecorderStarting:{
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
        }
        break;
			
		case kAudioRecorderPlaying:{
			[self.soundPlayer stop];
            if(!self.previewMode)
                mode = kAudioRecorderRecordingComplete;
            else
                mode = kAudioRecorderNoteMode;
                
			[self updateButtonsForCurrentMode];
        }
        break;	
			
		case kAudioRecorderRecordingComplete:{
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
        }
        break;
			
		case kAudioRecorderRecording:{
			[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
			
			[soundRecorder stop];
			self.soundRecorder = nil;
			mode = kAudioRecorderRecordingComplete;			
			[self updateButtonsForCurrentMode];
        }
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
    
    [[[AppModel sharedAppModel]uploadManager] uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:kNoteContentTypeAudio withFileURL:self.soundFileURL];
    
    [self.navigationController popViewControllerAnimated:YES];

}	

- (IBAction) discardButtonAction: (id) sender{
	soundPlayer = nil;
	mode = kAudioRecorderStarting;
	[self updateButtonsForCurrentMode];
}



- (void)updateMeter {
	[self.soundRecorder updateMeters];
	float levelInDb = [self.soundRecorder averagePowerForChannel:0];
	levelInDb = levelInDb + 160;
	
	//Level will always be between 0 and 160 now
	//Usually it will sit around 100 in quiet so we need to correct
	levelInDb = MAX(levelInDb - 100,0);
	float levelInZeroToOne = levelInDb / 60;
	
	NSLog(@"AudioRecorderLevel: %f, level in float:%f",levelInDb,levelInZeroToOne);
	
	[self.meter updateLevel:levelInZeroToOne];
}





#pragma mark Audio Recorder Delegate Metods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
	NSLog(@"audioRecorderDidFinishRecording");
	[self.meterUpdateTimer invalidate];
	[self.meter updateLevel:0];
	self.meter.alpha = 0.0; 
	
	mode = kAudioRecorderRecordingComplete;
	[self updateButtonsForCurrentMode];
	
	
}

#pragma mark Audio Player Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	NSLog(@"audioPlayerDidFinishPlaying");
	[[AVAudioSession sharedInstance] setActive: NO error: nil];
    
	soundPlayer = nil;
	
	mode = kAudioRecorderRecordingComplete;
	[self updateButtonsForCurrentMode];
	
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	NSLog(@"AudioRecorder: Playback Error");
}


@end
