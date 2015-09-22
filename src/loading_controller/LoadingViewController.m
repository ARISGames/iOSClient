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
    UILabel *mediaLabel;
    UILabel *mediaCountLabel;
    int mediaCount;

    UIButton *retryGameLoadButton;
    UIButton *retryPlayerLoadButton;
    UIButton *retryMediaDataLoadButton;

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
        _ARIS_NOTIF_LISTEN_(@"MODEL_MEDIA_DATA_LOADED",       self, @selector(mediaDataLoaded),   nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_MEDIA_DATA_COMPLETE",     self, @selector(mediaDataComplete), nil);
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
    mediaLabel = [[UILabel alloc] init];
    mediaCountLabel = [[UILabel alloc] init];
    progressBar = [[UIProgressView alloc] init];
    retryGameLoadButton = [[UIButton alloc] init];
    retryPlayerLoadButton = [[UIButton alloc] init];
    retryMediaDataLoadButton = [[UIButton alloc] init];

    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    progressLabel.font = [ARISTemplate ARISCellSubtextFont];
    progressLabel.textColor = [UIColor ARISColorDarkBlue];
  
    mediaLabel.text = @"Fetching Media... (this could take a while)";
    mediaLabel.font = [ARISTemplate ARISCellSubtextFont];
    mediaLabel.textColor = [UIColor ARISColorDarkBlue];
  
    mediaCountLabel.text = @"0 loaded...";
    mediaCountLabel.font = [ARISTemplate ARISCellSubtextFont];
    mediaCountLabel.textColor = [UIColor ARISColorDarkBlue];

    progressBar.progress = 0.0;
    progressBar.progressTintColor = [UIColor ARISColorDarkBlue];

    [retryGameLoadButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [retryGameLoadButton setTitle:@"Load Failed; Retry?" forState:UIControlStateNormal];
    [retryGameLoadButton addTarget:self action:@selector(retryGameFetch) forControlEvents:UIControlEventTouchUpInside];

    [retryPlayerLoadButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [retryPlayerLoadButton setTitle:@"Load Failed; Retry?" forState:UIControlStateNormal];
    [retryPlayerLoadButton addTarget:self action:@selector(retryPlayerFetch) forControlEvents:UIControlEventTouchUpInside];


    [retryMediaDataLoadButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    [retryMediaDataLoadButton setTitle:@"Load Failed; Retry?" forState:UIControlStateNormal];
    [retryMediaDataLoadButton addTarget:self action:@selector(retryMediaDataFetch) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:progressLabel];
    [self.view addSubview:progressBar];
}

- (void) viewDidAppear:(BOOL)animated
{
    progressLabel.frame = CGRectMake(10, 60, self.view.frame.size.width-20, 40);
    mediaLabel.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 40);
    mediaCountLabel.frame = CGRectMake(10, 120, self.view.frame.size.width-20, 40);
    progressBar.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 10);
    progressBar.progress = 0;

    retryGameLoadButton.frame   = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height/2-25,50,50);
    retryPlayerLoadButton.frame = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height/2-25,50,50);
    retryMediaDataLoadButton.frame = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height/2-25,50,50);

    [retryGameLoadButton removeFromSuperview];
    [retryPlayerLoadButton removeFromSuperview];
    [retryMediaDataLoadButton removeFromSuperview];
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
  if(_MODEL_GAME_.preload_media)
  {
    [self.view addSubview:mediaLabel];
    [self.view addSubview:mediaCountLabel];
    [self performSelector:@selector(sendOffRequestMediaData) withObject:nil afterDelay:1]; //to let added subviews render...
  }
  else
  {
    [_MODEL_ beginGame];
  }
}

- (void) sendOffRequestMediaData //this is only a function so it can fit in 'performselector'
{
  [_MODEL_MEDIA_ requestMediaData];
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

- (void) mediaDataLoaded
{
  mediaCount++;
  mediaCountLabel.text = [NSString stringWithFormat:@"%d loaded...",mediaCount];
}

- (void) mediaDataComplete
{
  [_MODEL_ beginGame];
}

- (void) mediaDataFetchFailed
{
    [self.view addSubview:retryMediaDataLoadButton];
}

- (void) retryMediaDataFetch
{
    [retryMediaDataLoadButton removeFromSuperview];
    [_MODEL_MEDIA_ requestMediaData];
}

- (void) percentLoaded:(NSNotification *)notif
{
    progressBar.progress = [notif.userInfo[@"percent"] floatValue];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
