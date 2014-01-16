//
//  NoteRecorderViewController.m
//  ARIS
//
//  Created by Brian Deith on 3/18/10.
//

#import "NoteRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "ARISTemplate.h"
#import "AudioVisualizerViewController.h"

@interface NoteRecorderViewController() <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, AudioVisualizerViewControllerDelegate>
{
    AVAudioSession *session;
	AVAudioRecorder *recorder;
	AVAudioPlayer *player;
    
    NSURL *audioFileURL;
    BOOL hasFile;
    
    UIButton *recordButton;
    UIButton *finishButton;   
    UIButton *playButton; 
    UIButton *stopButton;  
    UIButton *editButton;
   	UIButton *discardButton; 
   	UIButton *saveButton; 
    
    id<NoteRecorderViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteRecorderViewController

- (id) initWithDelegate:(id<NoteRecorderViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"AudioRecorderTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"microphoneTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"microphoneTabBarSelected"]]; 
        delegate = d;
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"dd_MM_yyyy_HH_mm"]; 
        audioFileURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@_audio.m4a", [outputFormatter stringFromDate:[NSDate date]]]]];     
        
        session = [AVAudioSession sharedInstance];
        session.delegate = self; 
        
        hasFile = NO; 
        
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    recordButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton  = [UIButton buttonWithType:UIButtonTypeCustom];  
    playButton    = [UIButton buttonWithType:UIButtonTypeCustom]; 
    stopButton    = [UIButton buttonWithType:UIButtonTypeCustom];  
    editButton    = [UIButton buttonWithType:UIButtonTypeCustom]; 
    discardButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    saveButton    = [UIButton buttonWithType:UIButtonTypeCustom]; 
       
    recordButton.frame  = CGRectMake(10,74, self.view.bounds.size.width-20,30);
    finishButton.frame  = CGRectMake(10,74, self.view.bounds.size.width-20,30);  
    playButton.frame    = CGRectMake(10,74, self.view.bounds.size.width-20,30); 
    stopButton.frame    = CGRectMake(10,74, self.view.bounds.size.width-20,30);  
    editButton.frame    = CGRectMake(10,114, self.view.bounds.size.width-20,30); 
    discardButton.frame = CGRectMake(10,154, self.view.bounds.size.width-20,30); 
    saveButton.frame    = CGRectMake(10,194,self.view.bounds.size.width-20,30); 
          
    //[recordButton  setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    //[finishButton  setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    //[playButton    setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    //[stopButton    setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    //[editButton    setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    //[discardButton setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    //[saveButton    setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    
    [recordButton  setTitle:NSLocalizedString(@"BeginRecordingKey",@"") forState:UIControlStateNormal];
    [finishButton  setTitle:NSLocalizedString(@"FinishKey",@"")         forState:UIControlStateNormal]; 
    [playButton    setTitle:NSLocalizedString(@"PlayKey",@"")           forState:UIControlStateNormal];
    [stopButton    setTitle:NSLocalizedString(@"StopKey",@"")           forState:UIControlStateNormal];
    [editButton    setTitle:NSLocalizedString(@"EditKey",@"")           forState:UIControlStateNormal];
   	[discardButton setTitle:NSLocalizedString(@"DiscardKey",@"")        forState:UIControlStateNormal];
   	[saveButton    setTitle:NSLocalizedString(@"SaveKey",@"")           forState:UIControlStateNormal];
    
    [recordButton  addTarget:self action:@selector(recordButtonTouched)  forControlEvents:UIControlEventTouchUpInside];
    [finishButton  addTarget:self action:@selector(finishButtonTouched)  forControlEvents:UIControlEventTouchUpInside]; 
    [playButton    addTarget:self action:@selector(playButtonTouched)    forControlEvents:UIControlEventTouchUpInside];
    [stopButton    addTarget:self action:@selector(stopButtonTouched)    forControlEvents:UIControlEventTouchUpInside];
    [editButton    addTarget:self action:@selector(editButtonTouched)    forControlEvents:UIControlEventTouchUpInside];
   	[discardButton addTarget:self action:@selector(discardButtonTouched) forControlEvents:UIControlEventTouchUpInside];
   	[saveButton    addTarget:self action:@selector(saveButtonTouched)    forControlEvents:UIControlEventTouchUpInside]; 
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouched)];
    
    [self refreshViewFromState];
}

- (void) refreshViewFromState
{
    [recordButton  removeFromSuperview];
    [finishButton  removeFromSuperview]; 
    [playButton    removeFromSuperview]; 
    [stopButton    removeFromSuperview]; 
    [editButton    removeFromSuperview]; 
    [discardButton removeFromSuperview];  
    [saveButton    removeFromSuperview];   
    
    if(recorder)
    {
        [self.view addSubview:finishButton];
    }
    else if(player)
    {
        [self.view addSubview:stopButton];
    }
    else if(hasFile)
    {
        [self.view addSubview:playButton]; 
        [self.view addSubview:editButton]; 
        [self.view addSubview:discardButton]; 
        [self.view addSubview:saveButton]; 
    }
    else
    {
        [self.view addSubview:recordButton]; 
    }
}

- (void) backButtonTouched
{
    [delegate recorderViewControllerCancelled]; 
}

- (void) recordButtonTouched
{
    [self beginRecording];
}

- (void) finishButtonTouched
{
    [self finishRecording];
}

- (void) playButtonTouched
{
    [self play];
}

- (void) stopButtonTouched
{
    [self stopPlaying];
}

- (void) editButtonTouched
{
    [self editAudio];
}

- (void) discardButtonTouched
{
    hasFile = NO;
    [self refreshViewFromState];
}

- (void) saveButtonTouched
{
    [self saveAudio];
}

- (void) beginRecording
{
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:44100.0],              AVSampleRateKey,
                                    [NSNumber numberWithInt:1],                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin],    AVSampleRateConverterAudioQualityKey,
                                    nil];
    recorder = [[AVAudioRecorder alloc] initWithURL:audioFileURL settings:recordSettings error:nil];
    recorder.delegate = self;
    [recorder setMeteringEnabled:YES];
    [recorder prepareToRecord];
    [session setActive:YES error:nil];
    [recorder record];
    
    [self refreshViewFromState];
}

- (void) finishRecording
{
    [recorder stop];
    [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error: nil];
    recorder = nil; 
    hasFile = YES;
    
    [self refreshViewFromState]; 
}

- (void) play
{
    [session setCategory: AVAudioSessionCategoryPlayback error: nil];
    [session setActive: YES error: nil];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    [player prepareToPlay];
    [player setDelegate: self];
    [player play]; 
    
    [self refreshViewFromState];  
}

- (void) stopPlaying
{
    [player stop]; 
    player = nil;
    
    [self refreshViewFromState];   
}

- (void) editAudio
{
    AudioVisualizerViewController *audioVC = [[AudioVisualizerViewController alloc] initWithAudioURL:audioFileURL delegate:self];
    [self.navigationController pushViewController:audioVC animated:YES];
}

- (void) saveAudio
{
    recorder = nil;
    [delegate audioChosenWithURL:audioFileURL];
}

- (void) fileWasTrimmed
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) dealloc
{
    session.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
