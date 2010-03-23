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


@interface AudioRecorderViewController : UIViewController <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
	AppModel *appModel;	

	AVAudioRecorder *soundRecorder;
	AVAudioPlayer *soundPlayer;
	NSURL *soundFileURL;
	IBOutlet UIButton *recordOrStopButton;
	IBOutlet UIButton *playOrPauseButton;
	IBOutlet UIButton *uploadButton;

	BOOL recording;
	BOOL playing;

}

@property(readwrite, retain) NSURL *soundFileURL;
@property(readwrite, retain) AVAudioRecorder *soundRecorder;
@property(readwrite, retain) AVAudioPlayer *soundPlayer;

- (IBAction) recordOrStop: (id) sender;
- (IBAction) playOrPause: (id) sender;
- (IBAction) upload: (id) sender;

@end

