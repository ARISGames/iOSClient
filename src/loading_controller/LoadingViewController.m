//
//  LoadingViewController.m
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"

@interface LoadingViewController()
{
  UIImageView *splashImage;

  UIProgressView *gameProgressBar;        UILabel *gameProgressLabel;        UIButton *gameRetryLoadButton;
  UIProgressView *maintenanceProgressBar; UILabel *maintenanceProgressLabel; UIButton *maintenanceRetryLoadButton;
  UIProgressView *playerProgressBar;      UILabel *playerProgressLabel;      UIButton *playerRetryLoadButton;
  UIProgressView *mediaProgressBar;       UILabel *mediaProgressLabel;       UIButton *mediaRetryLoadButton;

  id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation LoadingViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
  if(self = [super init])
  {
    delegate = d;
  
    _ARIS_NOTIF_LISTEN_(@"GAME_PERCENT_LOADED",               self, @selector(gamePercentLoaded:),        nil);
    _ARIS_NOTIF_LISTEN_(@"MAINTENANCE_PERCENT_LOADED",        self, @selector(maintenancePercentLoaded:), nil);
    _ARIS_NOTIF_LISTEN_(@"PLAYER_PERCENT_LOADED",             self, @selector(playerPercentLoaded:),      nil);
    _ARIS_NOTIF_LISTEN_(@"MEDIA_PERCENT_LOADED",              self, @selector(mediaPercentLoaded:),       nil);
  
    _ARIS_NOTIF_LISTEN_(@"GAME_DATA_LOADED",                  self, @selector(gameDataLoaded),         nil);
    _ARIS_NOTIF_LISTEN_(@"MAINTENANCE_DATA_LOADED",           self, @selector(maintenanceDataLoaded),  nil);
    _ARIS_NOTIF_LISTEN_(@"PLAYER_DATA_LOADED",                self, @selector(playerDataLoaded),       nil);
    _ARIS_NOTIF_LISTEN_(@"MEDIA_DATA_LOADED",                 self, @selector(mediaDataLoaded),        nil);
  
    _ARIS_NOTIF_LISTEN_(@"SERVICES_GAME_FETCH_FAILED",        self, @selector(gameFetchFailed),        nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_MAINTENANCE_FETCH_FAILED", self, @selector(maintenanceFetchFailed), nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_FETCH_FAILED",      self, @selector(playerFetchFailed),      nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_MEDIA_FETCH_FAILED",       self, @selector(mediaFetchFailed),      nil);
  }
  return self;
}

//for easy/consistent styling
- (void) setupLabel:(UILabel *)l progressBar:(UIProgressView *)p retryButton:(UIButton *)r
{
  l.font = [ARISTemplate ARISCellSubtextFont];
  l.textColor = [UIColor ARISColorDarkBlue];
  p.progress = 0.0;
  p.progressTintColor = [UIColor ARISColorDarkBlue];
  [r setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
  [r setTitle:@"Load Failed; Retry?" forState:UIControlStateNormal];
}

- (void) loadView
{
  [super loadView];
  self.view.backgroundColor = [UIColor ARISColorOffWhite];

  gameProgressLabel = [[UILabel alloc] init];
  gameProgressBar = [[UIProgressView alloc] init];
  gameRetryLoadButton = [[UIButton alloc] init];
  [self setupLabel:gameProgressLabel progressBar:gameProgressBar retryButton:gameRetryLoadButton];
  gameProgressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
  [gameRetryLoadButton addTarget:self action:@selector(retryGameFetch) forControlEvents:UIControlEventTouchUpInside];
  
  maintenanceProgressLabel = [[UILabel alloc] init];
  maintenanceProgressBar = [[UIProgressView alloc] init];
  maintenanceRetryLoadButton = [[UIButton alloc] init];
  [self setupLabel:maintenanceProgressLabel progressBar:maintenanceProgressBar retryButton:maintenanceRetryLoadButton];
  maintenanceProgressLabel.text = @"Performing Maintenance...";
  [maintenanceRetryLoadButton addTarget:self action:@selector(retryMaintenanceFetch) forControlEvents:UIControlEventTouchUpInside];
  
  playerProgressLabel = [[UILabel alloc] init];
  playerProgressBar = [[UIProgressView alloc] init];
  playerRetryLoadButton = [[UIButton alloc] init];
  [self setupLabel:playerProgressLabel progressBar:playerProgressBar retryButton:playerRetryLoadButton];
  playerProgressLabel.text = @"Fetching Player Data...";
  [playerRetryLoadButton addTarget:self action:@selector(retryPlayerFetch) forControlEvents:UIControlEventTouchUpInside];
  
  mediaProgressLabel = [[UILabel alloc] init];
  mediaProgressBar = [[UIProgressView alloc] init];
  mediaRetryLoadButton = [[UIButton alloc] init];
  [self setupLabel:mediaProgressLabel progressBar:mediaProgressBar retryButton:mediaRetryLoadButton];
  mediaProgressLabel.text = @"Fetching Media (this could take a while)...";
  [mediaRetryLoadButton addTarget:self action:@selector(retryMediaFetch) forControlEvents:UIControlEventTouchUpInside];
}

//for easy/consistent styling
- (void) frameLabel:(UILabel *)l progressBar:(UIProgressView *)p retryButton:(UIButton *)r atOffset:(float)o
{
  l.frame = CGRectMake(10,    o, self.view.frame.size.width-20, 40);
  p.frame = CGRectMake(10, 40+o, self.view.frame.size.width-20, 10);
  r.frame = CGRectMake(self.view.frame.size.width/2-25,self.view.frame.size.height/2+80,50,50);
}

- (void) viewDidAppear:(BOOL)animated
{
  [self frameLabel:gameProgressLabel        progressBar:gameProgressBar        retryButton:gameRetryLoadButton        atOffset:60.];
  [self frameLabel:maintenanceProgressLabel progressBar:maintenanceProgressBar retryButton:maintenanceRetryLoadButton atOffset:110.];
  [self frameLabel:playerProgressLabel      progressBar:playerProgressBar      retryButton:playerRetryLoadButton      atOffset:160.];
  [self frameLabel:mediaProgressLabel       progressBar:mediaProgressBar       retryButton:mediaRetryLoadButton       atOffset:210.];
}

- (void) startLoading
{
  if(![_MODEL_GAME_ hasLatestDownload] || [_MODEL_GAME_.network_level isEqualToString:@"REMOTE"])
    [self requestGameData];
  else
  {
    [_MODEL_ restoreGameData];
    [self gameDataLoaded];
  }
}

//Game Data
- (void) requestGameData { [self.view addSubview:gameProgressLabel]; [self.view addSubview:gameProgressBar]; [_MODEL_GAME_ requestGameData]; }
- (void) gamePercentLoaded:(NSNotification *)notif { gameProgressBar.progress = [notif.userInfo[@"percent"] floatValue]; }
- (void) gameDataLoaded
{
  if(_MODEL_GAME_.downloadedVersion && [_DELEGATE_.reachability currentReachabilityStatus] == NotReachable) //offline but playable...
  {
    //skip maintenance step
    [_MODEL_ restorePlayerData];
    [self playerDataLoaded];
  }
  else if(![_MODEL_GAME_ hasLatestDownload] || !_MODEL_GAME_.begin_fresh || ![_MODEL_GAME_.network_level isEqualToString:@"LOCAL"]) //if !local, need to perform maintenance on server so it doesn't keep conflicting with local data
    [self requestMaintenanceData];
  else
  {
    //skip maintenance step
    [_MODEL_ restorePlayerData];
    [self playerDataLoaded];
  }
}
- (void) gameFetchFailed { [self.view addSubview:gameRetryLoadButton]; }
- (void) retryGameFetch
{
  [gameRetryLoadButton removeFromSuperview];
  [self requestGameData];
}

//Maintenance Data
- (void) requestMaintenanceData { [self.view addSubview:maintenanceProgressLabel]; [self.view addSubview:maintenanceProgressBar]; [_MODEL_GAME_ requestMaintenanceData]; }
- (void) maintenancePercentLoaded:(NSNotification *)notif { maintenanceProgressBar.progress = [notif.userInfo[@"percent"] floatValue]; }
- (void) maintenanceDataLoaded
{
  if(![_MODEL_GAME_ hasLatestDownload] || !_MODEL_GAME_.begin_fresh)
    [self requestPlayerData];
  else
  {
    [_MODEL_ restorePlayerData];
    [self playerDataLoaded];
  }
}
- (void) maintenanceFetchFailed { [self.view addSubview:maintenanceRetryLoadButton]; }
- (void) retryMaintenanceFetch
{
  [maintenanceRetryLoadButton removeFromSuperview];
  [self requestMaintenanceData];
}

//Player Data
- (void) requestPlayerData { [self.view addSubview:playerProgressLabel]; [self.view addSubview:playerProgressBar]; [_MODEL_GAME_ requestPlayerData]; }
- (void) playerPercentLoaded:(NSNotification *)notif { playerProgressBar.progress = [notif.userInfo[@"percent"] floatValue]; }
- (void) playerDataLoaded
{
  if(![_MODEL_GAME_ hasLatestDownload])
  {
    if(_MODEL_GAME_.preload_media) [self requestMediaData];
    else [_MODEL_ beginGame];
  }
  else
    [_MODEL_ beginGame];
}
- (void) playerFetchFailed { [self.view addSubview:playerRetryLoadButton]; }
- (void) retryPlayerFetch
{
  [playerRetryLoadButton removeFromSuperview];
  [self requestPlayerData];
}

//Media Data
- (void) requestMediaData { [self.view addSubview:mediaProgressLabel]; [self.view addSubview:mediaProgressBar]; [_MODEL_GAME_ requestMediaData]; }
- (void) mediaPercentLoaded:(NSNotification *)notif { mediaProgressBar.progress = [notif.userInfo[@"percent"] floatValue]; }
- (void) mediaDataLoaded { [_MODEL_ beginGame]; }
- (void) mediaFetchFailed { [self.view addSubview:mediaRetryLoadButton]; }
- (void) retryMediaFetch
{
    [mediaRetryLoadButton removeFromSuperview];
    [self requestMediaData];
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
