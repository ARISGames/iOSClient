//
//  LoadingViewController.m
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"

@interface LoadingViewController()
{
    IBOutlet UIImageView *splashImage;
    IBOutlet UIProgressView *progressBar;
    IBOutlet UILabel *progressLabel;
    
    UIButton *retryGameButton;
    UIButton *retryPlayerButton;
    
    int gameDatasToReceive;
    int receivedGameData;
    BOOL gameDataReceived;
    
    int playerDatasToReceive;
    int receivedPlayerData;
    BOOL playerDataReceived;
    
    int tabDataToReceive;
    int receivedTabData;
    BOOL tabDataReceived;
    
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
        
        gameDatasToReceive = 6;
        receivedGameData = 0;
        gameDataReceived = NO;
        
        playerDatasToReceive = 4;
        receivedPlayerData = 0;
        playerDataReceived = NO;
        
        tabDataToReceive = 1;
        receivedTabData = 0;
        tabDataReceived = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameDataReceived)   name:@"GamePieceReceived"   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDataReceived) name:@"PlayerPieceReceived" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabDataReceived) name:@"TabDataReceived" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFetchFailed) name:@"PlayerFetchFailed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameFetchFailed) name:@"GameFetchFailed" object:nil];
    }
    return self;
}

- (void) dealloc
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

- (void) gameDataReceived
{
    receivedGameData++;
    [self moveProgressBar];
}

- (void) gameFetchFailed
{
    retryGameButton = [[UIButton alloc] init];
    [retryGameButton setTitle:@"Retry" forState:UIControlStateNormal];
    retryGameButton.frame = CGRectMake(20,400,100,20);
    [retryGameButton addTarget:self action:@selector(gameFetchRetryRequested) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retryGameButton];
}

- (void) gameFetchRetryRequested
{
    receivedGameData = 0;
    [[AppServices sharedAppServices] fetchAllGameLists];
    [self moveProgressBar];
    [retryGameButton removeFromSuperview];
}

- (void) playerDataReceived
{
    receivedPlayerData++;
    [self moveProgressBar];
}

- (void) playerFetchFailed
{
    retryPlayerButton = [[UIButton alloc] init];
    [retryPlayerButton setTitle:@"Retry" forState:UIControlStateNormal];
    retryPlayerButton.frame = CGRectMake(20,400,100,20);
    [retryPlayerButton addTarget:self action:@selector(playerFetchRetryRequested) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retryPlayerButton];
}

- (void) playerFetchRetryRequested
{
    receivedPlayerData = 0;
    [[AppServices sharedAppServices] fetchAllPlayerLists];
    [self moveProgressBar];
    [retryPlayerButton removeFromSuperview];
}

- (void) tabDataReceived
{
    receivedTabData++;
    [self moveProgressBar];
}

- (void) moveProgressBar
{
    float percentLoaded = ((float)(receivedGameData+receivedPlayerData+receivedTabData)/(float)(gameDatasToReceive+playerDatasToReceive+tabDataToReceive));
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
    if (!tabDataReceived && ((float)receivedTabData/(float)tabDataToReceive) >= 1.0-epsillon) {
        tabDataReceived = YES;
        [delegate loadingViewControllerFinishedLoadingTabData];
    }
    if(!playerDataReceived && ((float)receivedPlayerData/(float)playerDatasToReceive) >= 1.0-epsillon)
    {
        playerDataReceived = YES;
        [delegate loadingViewControllerFinishedLoadingPlayerData];
    }
    if(percentLoaded >= 1.0-epsillon)
    {
        receivedGameData   = 0;
        gameDataReceived   = NO;
        receivedPlayerData = 0;
        playerDataReceived = NO;
        receivedTabData = 0;
        tabDataReceived = NO;
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
