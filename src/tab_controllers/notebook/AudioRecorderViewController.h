//
//  AudioRecorderViewController.h
//  AudioDemo
//
//  Created by Brian Deith on 3/18/10.
//  Copyright Dept. of Journalism - University of Wisconsin - Madison 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

typedef enum {
	kAudioRecorderStarting,
	kAudioRecorderRecording,
	kAudioRecorderRecordingComplete,
	kAudioRecorderPlaying,
    kAudioRecorderNoteMode
} AudioRecorderModeType;

@protocol AudioRecorderViewControllerDelegate
- (void) audioChosenWith:(NSURL *)url;
- (void) audioRecorderViewControllerCancelled;
@end

@interface AudioRecorderViewController : ARISViewController
- (id) initWithDelegate:(id<AudioRecorderViewControllerDelegate>)d;
@end
