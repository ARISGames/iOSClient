//
//  AudioRecorderViewController.m
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import "ARISAppDelegate.h"

@implementation AudioRecorderViewController
@synthesize soundFileURL;
@synthesize soundRecorder;
@synthesize soundPlayer;



// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Audio Recorder";
        self.tabBarItem.image = [UIImage imageNamed:@"camera.png"];
		
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
	
	NSString *tempDir = NSTemporaryDirectory ();
    NSString *soundFilePath =[tempDir stringByAppendingString: @"sound.caf"];
	
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    self.soundFileURL = newURL;
    [newURL release];
	
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //audioSession.delegate = self;
    [audioSession setActive: YES error: nil];
	
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
	// if already playing, then pause
    if (playing) {
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateHighlighted];
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateNormal];
        [self.soundPlayer pause];
		
		// if stopped or paused, start playing
    } else {
        [playOrPauseButton setTitle: @"Pause" forState: UIControlStateHighlighted];
        [playOrPauseButton setTitle: @"Pause" forState: UIControlStateNormal];
		if (nil == self.soundPlayer) {
			AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFileURL error: nil];
			self.soundPlayer = newPlayer;
			[newPlayer release];
			[self.soundPlayer prepareToPlay];
			[self.soundPlayer setDelegate: self];
		}			
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
		[[AVAudioSession sharedInstance] setActive: NO error: nil];
		
	} else {
		
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: nil];
		
		NSDictionary *recordSettings =
		[[NSDictionary alloc] initWithObjectsAndKeys:
		 [NSNumber numberWithFloat: 22050.0], AVSampleRateKey,
		 [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
		 [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
		 [NSNumber numberWithInt: AVAudioQualityMax],
		 AVEncoderAudioQualityKey,
		 nil];
		
		AVAudioRecorder *newRecorder = [[AVAudioRecorder alloc] initWithURL: soundFileURL settings: recordSettings error: nil];
		[recordSettings release];
		self.soundRecorder = newRecorder;
		[newRecorder release];
		
		soundRecorder.delegate = self;
		[soundRecorder setMeteringEnabled:YES];
		[soundRecorder prepareToRecord];
		[soundRecorder record];
		NSLog(@"Recording.");
		[recordOrStopButton setTitle: @"Stop" forState: UIControlStateNormal];
		[recordOrStopButton setTitle: @"Stop" forState: UIControlStateHighlighted];
		
		recording = YES;
	}
}

- (IBAction)upload:(id)sender {
	NSLog(@"AudioRecorder:Upload Button Pressed");
	// if playing, then pause
    if (playing) {
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateHighlighted];
        [playOrPauseButton setTitle: @"Play" forState: UIControlStateNormal];
        [self.soundPlayer pause];
	}

	NSData *audioData = [NSData dataWithContentsOfURL:soundFileURL];
	[appModel createItemAndGiveToPlayerFromFileData:audioData andFileName:@"audio.caf"];
	
}


#pragma mark Audio Recorder Delegate Metods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
	recording = NO;
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


@end
