//
//  RootViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"

#import "AppModel.h"
#import "ARISAlertHandler.h"

#import "LoginViewController.h"
#import "PlayerSettingsViewController.h"
#import "GamePickersViewController.h"
#import "GamePlayViewController.h"

#import "ARISNavigationController.h"

#import "AppServices.h"

@interface RootViewController () <UINavigationControllerDelegate, LoginViewControllerDelegate, PlayerSettingsViewControllerDelegate, GamePickersViewControllerDelegate, GamePlayViewControllerDelegate>
{
    ARISNavigationController *loginNavigationController;
    ARISNavigationController *playerSettingsNavigationController;
    GamePickersViewController *gamePickersViewController;
    GamePlayViewController *gamePlayViewController;
}

@end

@implementation RootViewController

+ (id) sharedRootViewController
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id) init
{
    if(self = [super init])
    {
        loginNavigationController = 
            [[ARISNavigationController alloc] initWithRootViewController:
                [[LoginViewController alloc] initWithDelegate:self]
             ];
        
        playerSettingsNavigationController = 
            [[ARISNavigationController alloc] initWithRootViewController:
                [[PlayerSettingsViewController alloc] initWithDelegate:self]
             ];
        
        gamePickersViewController = [[GamePickersViewController alloc] initWithDelegate:self];  
        
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_IN",self,@selector(playerLoggedIn),nil); 
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_OUT",self,@selector(playerLoggedOut),nil);
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!_MODEL_PLAYER_)
        [self displayContentController:loginNavigationController];
    else if(!_MODEL_GAME_)
        [self displayContentController:gamePickersViewController]; 
}

- (void) playerLoggedOut
{
    gamePlayViewController = nil;
    [self displayContentController:loginNavigationController];  
}

- (void) playerLoggedIn
{
    if(!_MODEL_PLAYER_.display_name || !_MODEL_PLAYER_.media_id)
        [self displayContentController:playerSettingsNavigationController];
    else if(!_MODEL_GAME_)
        [self displayContentController:gamePickersViewController]; 
    else if(gamePlayViewController)
        [self displayContentController:gamePlayViewController];  
}

- (void) playerSettingsRequested
{
    //PHIL HATES THIS NEXT CHUNK
    [(PlayerSettingsViewController *)playerSettingsNavigationController.topViewController resetState];
    [self displayContentController:playerSettingsNavigationController];
    //PHIL DONE HATING CHUNK
}

- (void) playerSettingsWasDismissed
{
    //PHIL HATES THIS CHUNK
    if(_MODEL_.fallbackGameId)
    {
  _ARIS_NOTIF_LISTEN_(@"NewOneGameGameListReady",self,@selector(singleGameRequestReady:),nil);
        [_SERVICES_ fetchOneGameGameList:_MODEL_.fallbackGameId];
        [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:[NSString stringWithFormat:@"%@...", NSLocalizedString(@"ConfirmingKey", @"")]];
    }
    else
        [self displayContentController:gamePickersViewController];
    //PHIL DONE HATING THIS CHUNK
}

- (void) singleGameRequestReady:(NSNotification *)n
{
    [[ARISAlertHandler sharedAlertHandler] removeNetworkAlert];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewOneGameGameListReady" object:nil];
    [self gamePickedForPlay:[n.userInfo objectForKey:@"game"]];
    _MODEL_.fallbackGameId = 0; // PHIL HATES THIS
}

- (void) gamePickedForPlay:(Game *)g
{
    [_PUSHER_ loginGame:g.game_id]; 
    gamePlayViewController = [[GamePlayViewController alloc] initWithGame:g delegate:self];
    [self displayContentController:gamePlayViewController];
}

- (void) gameplayWasDismissed
{
    [_PUSHER_ logoutGame];  
    [self displayContentController:gamePickersViewController];
    gamePlayViewController = nil; 
    
    //PHIL HATES THIS CHUNK
    _MODEL_.fallbackGameId = 0;
    [_MODEL_ saveUserDefaults];
    //PHIL DONE HATING THIS CHUNK
}

@end
