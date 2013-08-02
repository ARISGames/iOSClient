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
    IBOutlet UIImageView *splashImage;
    IBOutlet UIProgressView *progressBar;
    IBOutlet UILabel *progressLabel;
    
    int gameDatasToReceive;
    int receivedGameData;
    BOOL gameDataReceived;
    
    int playerDatasToReceive;
    int receivedPlayerData;
    BOOL playerDataReceived;
    
    float epsillon;

    id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}

@property(nonatomic)IBOutlet UIImageView *splashImage;
@property(nonatomic)IBOutlet UIProgressView *progressBar;
@property(nonatomic)IBOutlet UILabel *progressLabel;

@end

@implementation LoadingViewController

@synthesize splashImage;
@synthesize progressBar;
@synthesize progressLabel;

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
    if(self = [super initWithNibName:@"LoadingViewController" bundle:nil])
    {
        delegate = d;
        
        epsillon = 0.00001;
        
        gameDatasToReceive = 7;
        receivedGameData = 0;
        gameDataReceived = NO;
        
        playerDatasToReceive = 4;
        receivedPlayerData = 0;
        playerDataReceived = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameDataReceived)   name:@"GamePieceReceived"   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDataReceived) name:@"PlayerPieceReceived" object:nil];
    }
    return self;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    progressBar.progress = 0.0;
    [self moveProgressBar];
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
    [progressBar setNeedsLayout];
    [progressBar setNeedsDisplay];
    [progressLabel setNeedsDisplay];
    [progressLabel setNeedsLayout];
    
    if(!gameDataReceived && ((float)receivedGameData/(float)gameDatasToReceive) >= 1.0-epsillon)
    {
        gameDataReceived = YES;
        [delegate loadingViewControllerFinishedLoadingGameData];
    }
    if(!playerDataReceived && ((float)receivedPlayerData/(float)playerDatasToReceive) >= 1.0-epsillon)
    {
        playerDataReceived = YES;
        [delegate loadingViewControllerFinishedLoadingPlayerData];
    }
    if(percentLoaded >= 1.0-epsillon)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        [delegate loadingViewControllerFinishedLoadingData];
        receivedGameData   = 0;
        gameDataReceived   = NO;
        receivedPlayerData = 0;
        playerDataReceived = NO;
    }
}

- (NSInteger) supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

@end
