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

    UIButton *retryGameLoadButton;
    UIButton *retryPlayerLoadButton;

    id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation LoadingViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PERCENT_LOADED",     self, @selector(percentLoaded:),    nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_DATA_LOADED",        self, @selector(gameDataLoaded),    nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PLAYER_DATA_LOADED", self, @selector(playerDataLoaded),  nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_GAME_FETCH_FAILED",    self, @selector(gameFetchFailed),   nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_FETCH_FAILED",  self, @selector(playerFetchFailed), nil);
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorOffWhite];

    progressLabel = [[UILabel alloc] init];
    progressBar = [[UIProgressView alloc] init];
    retryGameLoadButton = [[UIButton alloc] init];
    retryPlayerLoadButton = [[UIButton alloc] init];

    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    progressLabel.font = [ARISTemplate ARISCellSubtextFont];
    progressLabel.textColor = [UIColor ARISColorDarkBlue];

    progressBar.progress = 0.0;
    progressBar.progressTintColor = [UIColor ARISColorDarkBlue];

    [retryGameLoadButton setTitle:@"Retry?" forState:UIControlStateNormal];
    [retryGameLoadButton addTarget:self action:@selector(retryGameFetch) forControlEvents:UIControlEventTouchUpInside];
    
    [retryPlayerLoadButton setTitle:@"Retry?" forState:UIControlStateNormal];
    [retryPlayerLoadButton addTarget:self action:@selector(retryPlayerFetch) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:progressLabel];
    [self.view addSubview:progressBar];
}

- (void) viewDidAppear:(BOOL)animated
{
    progressLabel.frame = CGRectMake(10, 60, self.view.frame.size.width-20, 40);
    progressBar.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 10);
    
    retryGameLoadButton.frame = CGRectMake(10,200,100,20);
    retryPlayerLoadButton.frame = CGRectMake(10,200,100,20);
}

- (void) startLoading
{
    [_MODEL_GAME_ requestGameData];
}

- (void) gameDataLoaded
{
    [_MODEL_GAME_ requestPlayerData];
}

- (void) gameFetchFailed
{
    [self.view addSubview:retryGameLoadButton];
}

- (void) retryGameFetch
{
    [retryGameLoadButton removeFromSuperview];
    [_MODEL_GAME_ requestGameData];
}

- (void) playerDataLoaded
{
    [_MODEL_ beginGame];
}

- (void) playerFetchFailed
{
    [self.view addSubview:retryPlayerLoadButton];
}

- (void) retryPlayerFetch
{
    [retryPlayerLoadButton removeFromSuperview];
    [_MODEL_GAME_ requestPlayerData];
}

- (void) percentLoaded:(NSNotification *)notif
{
    progressBar.progress = [notif.userInfo[@"percent"] floatValue];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
