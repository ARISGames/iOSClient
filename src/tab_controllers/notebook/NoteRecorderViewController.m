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
#import "AudioMeter.h"
#import "CircleButton.h"

@interface NoteRecorderViewController() <AVAudioRecorderDelegate, AVAudioPlayerDelegate, AudioMeterDelegate, AudioVisualizerViewControllerDelegate, UIActionSheetDelegate>
{
    AVAudioSession *session;
	AVAudioRecorder *recorder;
	AVAudioPlayer *player;
    
    NSURL *audioFileURL;
    BOOL hasFile;
    
    CircleButton *recordButton;
    UIButton *finishButton;   
    UIButton *playButton; 
    UIButton *stopButton;  
    UIButton *editButton;
   	UIButton *discardButton; 
   	UIButton *saveButton; 
    
    UIActionSheet *confirmPrompt; 
    
    AudioMeter *meter;
    
    id<NoteRecorderViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteRecorderViewController

- (id) initWithDelegate:(id<NoteRecorderViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = @"Audio Note";
        delegate = d;
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"dd_MM_yyyy_HH_mm"]; 
        audioFileURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@_audio.m4a", [outputFormatter stringFromDate:[NSDate date]]]]];     
        
        session = [AVAudioSession sharedInstance];
        
        hasFile = NO; 
        
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIColor *fc = [UIColor whiteColor];
    UIColor *sc = [UIColor blackColor]; 
    UIColor *tc = [UIColor blackColor]; 
    int sw = 1;
    
    meter = [[AudioMeter alloc] initWithDelegate:self];
    [self.view addSubview:meter];
    
    recordButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
    [recordButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    finishButton = [[UIButton alloc] init];
    finishButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    finishButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;   
    [finishButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal]; 
    [finishButton addTarget:self action:@selector(finishButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    playButton = [[UIButton alloc] init]; 
    playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    playButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;  
    [playButton setImage:[UIImage imageNamed:@"dark_play.png"] forState:UIControlStateNormal];  
    [playButton addTarget:self action:@selector(playButtonTouched) forControlEvents:UIControlEventTouchUpInside];  
    
    stopButton = [[UIButton alloc] init];  
    stopButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    stopButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill; 
    [stopButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];   
    [stopButton addTarget:self action:@selector(stopButtonTouched) forControlEvents:UIControlEventTouchUpInside];   
    
    editButton = [[UIButton alloc] init]; 
    [editButton.layer setMasksToBounds:YES];
    [editButton.layer setCornerRadius:0.0]; //when radius is 0, the border is a rectangle
    [editButton.layer setBorderWidth:sw];
    [editButton.layer setBorderColor:[sc CGColor]];
    editButton.imageEdgeInsets = UIEdgeInsetsMake(3,3,3,3);
    [editButton setImage:[UIImage imageNamed:@"pencil.png"] forState:UIControlStateNormal];   
    [editButton addTarget:self action:@selector(editButtonTouched) forControlEvents:UIControlEventTouchUpInside];    
    
    discardButton = [[UIButton alloc] init]; 
    [discardButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];   
    [discardButton addTarget:self action:@selector(discardButtonTouched) forControlEvents:UIControlEventTouchUpInside];     
    discardButton.frame = CGRectMake(0,0, 20, 20);      
    
    saveButton = [[UIButton alloc] init];
    [saveButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];   
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];    
    saveButton.frame    = CGRectMake(0,0, 24, 24);    
    
    confirmPrompt = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Discard" otherButtonTitles:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshViewFromState];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    meter.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-64);
    
    int buttonDiameter = 50; 
    int buttonPadding = (self.view.frame.size.width-buttonDiameter)/2; 
    recordButton.frame  = CGRectMake(buttonPadding, self.view.bounds.size.height-60, buttonDiameter, buttonDiameter); 
    finishButton.frame  = CGRectMake(buttonPadding, self.view.bounds.size.height-60, buttonDiameter, buttonDiameter);  
    stopButton.frame    = CGRectMake(buttonPadding, self.view.bounds.size.height-60, buttonDiameter, buttonDiameter);    
    
    buttonPadding = ((self.view.frame.size.width/3)-buttonDiameter)/2; 
    editButton.frame    = CGRectMake(buttonPadding*1+buttonDiameter*0+20, self.view.bounds.size.height-60+10, buttonDiameter-20, buttonDiameter-20);    
    playButton.frame    = CGRectMake(buttonPadding*3+buttonDiameter*1, self.view.bounds.size.height-60, buttonDiameter, buttonDiameter); 
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopPlaying];
}

- (void) refreshViewFromState
{
    [recordButton  removeFromSuperview];
    [finishButton  removeFromSuperview]; 
    [playButton    removeFromSuperview]; 
    [stopButton    removeFromSuperview]; 
    [editButton    removeFromSuperview]; 
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];    
    self.navigationItem.rightBarButtonItem = nil;       
    
    if(recorder)
    {
        [self.view addSubview:finishButton];
    }
    else if(player)
    {
        [self.view addSubview:stopButton];
        self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:discardButton];      
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];      
    }
    else if(hasFile)
    {
        [self.view addSubview:playButton]; 
        [self.view addSubview:editButton]; 
        self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:discardButton];      
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];     
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
    confirmPrompt.title = @"Discard audio?";
    [confirmPrompt showInView:self.view]; 
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
    [meter startRequestingLevels];
    
    [self refreshViewFromState];
}

- (void) finishRecording
{
    [recorder stop];
    [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error: nil];
    recorder = nil; 
    hasFile = YES;
    [meter stopRequestingLevels];
    
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
    [meter startRequestingLevels];
    
    [self refreshViewFromState];  
}

- (void) stopPlaying
{
    [player stop]; 
    player = nil;
    [meter stopRequestingLevels]; 
    
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

- (void) discardAudio
{
    hasFile = NO;
    [self refreshViewFromState]; 
}

- (void) actionSheet:(UIActionSheet *)a clickedButtonAtIndex:(NSInteger)b
{
    if(b == 0) //discard
        [self discardAudio];
}

- (double) meterRequestsLevel:(AudioMeter *)m
{
    float levelInDb = 0.0f;
    if(player)
    {
        [player updateMeters];
         levelInDb = [player averagePowerForChannel:0]; 
    }
    else if(recorder)
    {
        [recorder updateMeters];
        levelInDb = [recorder averagePowerForChannel:0];
    }
    return MAX((levelInDb+50.0)/60.0,0.0); //Normalizes -50 through 10 to 0.0 through 1.0
}

- (void) fileWasTrimmed:(NSURL *)u
{
    audioFileURL = u;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlaying];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
