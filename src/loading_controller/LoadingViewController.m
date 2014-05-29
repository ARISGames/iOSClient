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
    
    id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation LoadingViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PERCENT_LOADED",     self, @selector(percentLoaded:),   nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_DATA_LOADED",        self, @selector(gameDataLoaded),   nil); 
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PLAYER_DATA_LOADED", self, @selector(playerDataLoaded), nil); 
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorOffWhite];
    
    progressLabel = [[UILabel alloc] init];
    progressBar = [[UIProgressView alloc] init]; 
    
    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @""); 
    progressLabel.font = [ARISTemplate ARISCellSubtextFont];
    progressLabel.textColor = [UIColor ARISColorDarkBlue]; 
    
    progressBar.progress = 0.0; 
    progressBar.progressTintColor = [UIColor ARISColorDarkBlue];
    
    [self.view addSubview:progressLabel]; 
    [self.view addSubview:progressBar]; 
}

- (void) viewDidAppear:(BOOL)animated
{
    progressLabel.frame = CGRectMake(10, 60, self.view.frame.size.width-20, 40);
    progressBar.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 10); 
}

- (void) startLoading
{
    [_MODEL_GAME_ requestGameData]; 
}

- (void) gameDataLoaded
{
    [_MODEL_GAME_ requestPlayerData];
}

- (void) playerDataLoaded
{
    [_MODEL_ beginGame];
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
