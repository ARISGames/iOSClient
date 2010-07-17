//
//  AudioRecorderViewController.h
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AppModel.h";
#import "AudioMeter.h"

typedef enum {
	kAudioRecorderStarting,
	kAudioRecorderRecording,
	kAudioRecorderRecordingComplete,
	kAudioRecorderPlaying
} modeType;


@interface AudioRecorderViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
	AppModel *appModel;	
	
	AudioMeter *meter;
	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
	NSURL *soundFileURL;
	NSData *audioData;
	IBOutlet UIButton *recordStopOrPlayButton;
	IBOutlet UIButton *uploadButton;
	IBOutlet UIButton *discardButton;
	modeType mode;
	BOOL recording;
	BOOL playing;
	NSTimer *meterUpdateTimer;
	
}

@property(readwrite, retain) AudioMeter *meter;
@property(readwrite, retain) NSURL *soundFileURL;
@property(readwrite, retain) NSData *audioData;
@property(readwrite, retain) AVAudioRecorder *soundRecorder;
@property(readwrite, retain) AVAudioPlayer *soundPlayer;
@property(readwrite, retain) NSTimer *meterUpdateTimer;


- (IBAction) recordStopOrPlayButtonAction: (id) sender;
- (IBAction) uploadButtonAction: (id) sender;
- (IBAction) discardButtonAction: (id) sender;
- (void) updateButtonsForCurrentMode;



@end

