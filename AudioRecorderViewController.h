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
	id backView, parentDelegate,editView;
}

@property(readwrite, retain) AudioMeter *meter;
@property(readwrite, retain) NSURL *soundFileURL;
@property(readwrite, retain) NSData *audioData;
@property(readwrite, retain) AVAudioRecorder *soundRecorder;
@property(readwrite, retain) AVAudioPlayer *soundPlayer;
@property(readwrite, retain) NSTimer *meterUpdateTimer;
@property(nonatomic, assign) id backView;
@property(nonatomic, assign) id parentDelegate;
@property(nonatomic, assign) id editView;


@property(readwrite, assign) int noteId;
@property(readwrite, assign) BOOL previewMode;


- (IBAction) recordStopOrPlayButtonAction: (id) sender;
- (IBAction) uploadButtonAction: (id) sender;
- (IBAction) discardButtonAction: (id) sender;
- (void) updateButtonsForCurrentMode;
- (NSString *)getUniqueId;



@end

