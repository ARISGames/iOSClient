//
//  LoadingViewController.m
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"

@interface LoadingViewController()
{
    UIImageView *splashImage;
    UIProgressView *progressBar;
    UILabel *progressLabel;
    
    int gameDatasToReceive;
    int receivedGameData;
    BOOL gameDataReceived;
    
    int playerDatasToReceive;
    int receivedPlayerData;
    BOOL playerDataReceived;
    
    id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation LoadingViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

-(void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);                 
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    progressBar.progress = 0.0;
    [self moveProgressBar];
}

- (void) viewDidAppear:(BOOL)animated
{
    //admittedly, an odd place to kick off loading of the model, but whatever
    [_MODEL_GAME_ requestData];
}

-(void) gameDataReceived
{
    receivedGameData++;
    [self moveProgressBar];
}

-(void) playerDataReceived
{
    receivedPlayerData++;
    [self moveProgressBar];
}

- (void) moveProgressBar
{
    float percentLoaded = ((float)(receivedGameData+receivedPlayerData)/(float)(gameDatasToReceive+playerDatasToReceive));
    progressBar.progress = percentLoaded;
    
    if(!gameDataReceived && receivedGameData == gameDatasToReceive)
    {
        gameDataReceived = YES;
        [delegate loadingViewControllerFinishedLoadingGameData];
    }
    if(!playerDataReceived && receivedPlayerData == playerDatasToReceive)
    {
        playerDataReceived = YES;
        [delegate loadingViewControllerFinishedLoadingPlayerData];
    }
    if(gameDataReceived && playerDataReceived)
    {
        receivedGameData   = 0;
        gameDataReceived   = NO;
        receivedPlayerData = 0;
        playerDataReceived = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
        [delegate loadingViewControllerFinishedLoadingData]; 
    }
}

- (NSUInteger) supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

@end
