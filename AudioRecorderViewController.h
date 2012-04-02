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
#import "AppModel.h"
#import "AudioMeter.h"

typedef enum {
	kAudioRecorderStarting,
	kAudioRecorderRecording,
	kAudioRecorderRecordingComplete,
	kAudioRecorderPlaying,
    kAudioRecorderNoteMode
} AudioRecorderModeType;


@interface AudioRecorderViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
	
	AudioMeter *meter;
	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
	NSURL *soundFileURL;
	NSData *audioData;
	IBOutlet UIButton *recordStopOrPlayButton;
	IBOutlet UIButton *uploadButton;
	IBOutlet UIButton *discardButton;
	AudioRecorderModeType mode;
	BOOL recording;
	BOOL playing;
    BOOL previewMode;
    int noteId;
	NSTimer *meterUpdateTimer;
	id backView, parentDelegate, editView;
}

@property(readwrite) AudioMeter *meter;
@property(readwrite) NSURL *soundFileURL;
@property(readwrite) NSData *audioData;
@property(readwrite) AVAudioRecorder *soundRecorder;
@property(readwrite) AVAudioPlayer *soundPlayer;
@property(readwrite) NSTimer *meterUpdateTimer;
@property(nonatomic) id backView;
@property(nonatomic) id parentDelegate;
@property(nonatomic) id editView;


@property(readwrite, assign) int noteId;
@property(readwrite, assign) BOOL previewMode;


- (IBAction) recordStopOrPlayButtonAction: (id) sender;
- (IBAction) uploadButtonAction: (id) sender;
- (IBAction) discardButtonAction: (id) sender;
- (void) updateButtonsForCurrentMode;
- (NSString *)getUniqueId;



@end

