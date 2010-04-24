//
//  AudioRecorderViewController.m
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import "ARISAppDelegate.h"
#import "TitleAndDecriptionFormViewController.h";

@implementation AudioRecorderViewController
@synthesize soundFileURL;
@synthesize soundRecorder;
@synthesize soundPlayer;
@synthesize meter;
@synthesize meterUpdateTimer;
@synthesize audioData;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Audio Recorder";
        self.tabBarItem.image = [UIImage imageNamed:@"microphone.png"];
		
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	meter = [[AudioMeter alloc]initWithFrame:CGRectMake(32, 20, 320-64, 160)];
	meter.alpha = 0.0;
	[self.view addSubview:meter];
	
	NSString *tempDir = NSTemporaryDirectory ();
    NSString *soundFilePath =[tempDir stringByAppendingString: @"sound.caf"];
	
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    self.soundFileURL = newURL;
    [newURL release];
	
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setDelegate: self];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
	
    recording = NO;
    playing = NO;
	
	[playOrPauseButton setAlpha:0.7];
	[playOrPauseButton setEnabled:NO];
	[uploadButton setAlpha:0.7];
	[uploadButton setEnabled:NO];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)playOrPause:(id)sender {
	NSLog(@"AudioRecorder: Play/Pause Button selected");
	// if already playing, then pause
    if (playing) {
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateHighlighted];
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateNormal];
        
		playing = NO;
		[self.soundPlayer stop];
		
		// if stopped or paused, start playing
    } else {
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];

		if (nil == self.soundPlayer) {
			NSError *error;
			AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error: &error];
			self.soundPlayer = newPlayer;
			[newPlayer release];
			[self.soundPlayer prepareToPlay];
			[self.soundPlayer setDelegate: self];
		}	
		playing = YES;
		[playOrPauseButton setTitle: @"Pause" forState: UIControlStateHighlighted];
        [playOrPauseButton setTitle: @"Pause" forState: UIControlStateNormal];
        [self.soundPlayer play];

    }
	
}


- (IBAction) recordOrStop: (id) sender {
	
	if (recording) {
		
		[soundRecorder stop];
		NSLog(@"Recording stopped.");
		recording = NO;
		self.soundRecorder = nil;
		
		[recordOrStopButton setTitle: @"Record" forState:UIControlStateNormal];
		[recordOrStopButton setTitle: @"Record" forState:UIControlStateHighlighted];
		
	} else {
		
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: nil];
		
		NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
										[NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
										[NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
										[NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
										[NSNumber numberWithInt: AVAudioQualityMax],AVEncoderAudioQualityKey,
										nil];
		
		AVAudioRecorder *newRecorder = [[AVAudioRecorder alloc] initWithURL: soundFileURL settings: recordSettings error: nil];
		[recordSettings release];
		self.soundRecorder = newRecorder;
		[newRecorder release];
		
		soundRecorder.delegate = self;
		[soundRecorder setMeteringEnabled:YES];
		[soundRecorder prepareToRecord];
		
		
		BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
		if (! audioHWAvailable) {
			UIAlertView *cantRecordAlert =
			[[UIAlertView alloc] initWithTitle: @"Warning"
									   message: @"Audio input hardware not available"
									  delegate: nil
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
			[cantRecordAlert show];
			[cantRecordAlert release]; 
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
		[recordOrStopButton setTitle: @"Stop" forState: UIControlStateNormal];
		[recordOrStopButton setTitle: @"Stop" forState: UIControlStateHighlighted];
		recording = YES;
	}
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


- (IBAction)upload:(id)sender {
	NSLog(@"AudioRecorder:Upload Button Pressed");
	// if playing, then pause
    if (playing) {
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateHighlighted];
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateNormal];
        [self.soundPlayer pause];
	}

	self.audioData = [NSData dataWithContentsOfURL:soundFileURL];
	
	TitleAndDecriptionFormViewController *titleAndDescForm = [[TitleAndDecriptionFormViewController alloc] 
															  initWithNibName:@"TitleAndDecriptionFormViewController" bundle:nil];
	titleAndDescForm.delegate = self;
	[self.view addSubview:titleAndDescForm.view];
}


- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm{
	NSLog(@"CameraVC: Back from form");
	[titleAndDescForm.view removeFromSuperview];
	
	
	[appModel createItemAndGiveToPlayerFromFileData:self.audioData 
										   fileName:@"audio.caf" 
											  title:titleAndDescForm.titleField.text 
										description:titleAndDescForm.descriptionField.text];
	
	
}



#pragma mark Audio Recorder Delegate Metods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
	recording = NO;
	[self.meterUpdateTimer invalidate];
	[self.meter updateLevel:0];
	self.meter.alpha = 0.0; 

	
	[recordOrStopButton setTitle: @"Record" forState:UIControlStateNormal];
	[recordOrStopButton setTitle: @"Record" forState:UIControlStateHighlighted];
	
	[playOrPauseButton setAlpha:1.0];
	[playOrPauseButton setEnabled:YES];
	[uploadButton setAlpha:1.0];
	[uploadButton setEnabled:YES];

}

#pragma mark Audio Player Delegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	playing = NO;
	[playOrPauseButton setTitle: @"Play" forState: UIControlStateHighlighted];
	[playOrPauseButton setTitle: @"Play" forState: UIControlStateNormal];
	soundPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	NSLog(@"AudioRecorder: Playback Error");
}


@end
