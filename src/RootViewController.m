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
#import "ARISPusherHandler.h"

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
        
        //PHIL HATES THIS
  _ARIS_NOTIF_LISTEN_(@"LogoutRequested",self,@selector(logoutWasRequested),nil);
        //PHIL DONE HATING
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!currentChildViewController)
        [self displayContentController:loginNavigationController];
}

- (void) loginCredentialsApprovedForPlayer:(User *)p toGame:(int)game_id newPlayer:(BOOL)newPlayer disableLeaveGame:(BOOL)disableLeaveGame
{
    /*
    [_MODEL_ commitPlayerLogin:p];
    
    //PHIL HATES THIS NEXT CHUNK
    _MODEL_.disableLeaveGame = disableLeaveGame;
    if(newPlayer)
    {
        [(PlayerSettingsViewController *)playerSettingsNavigationController.topViewController resetState];
        [self displayContentController:playerSettingsNavigationController];
    }
    if(game_id)
    {
        _MODEL_.skipGameDetails = game_id;
        if(!newPlayer)
        {
  _ARIS_NOTIF_LISTEN_(@"NewOneGameGameListReady",self,@selector(singleGameRequestReady:),nil);
  [_ARIS_NOTIF_LISTEN_(@"NewOneGameGameListFailed",self,@selector(singleGameRequestFailed:),nil);
            [_SERVICES_ fetchOneGameGameList:game_id];
        }
    }
    //PHIL DONE HATING CHUNK
    
    gamePickersViewController = [[GamePickersViewController alloc] initWithDelegate:self];
    
    if(!newPlayer && !game_id)
        [self displayContentController:gamePickersViewController];
     */
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
    if(_MODEL_.skipGameDetails)
    {
  _ARIS_NOTIF_LISTEN_(@"NewOneGameGameListReady",self,@selector(singleGameRequestReady:),nil);
  _ARIS_NOTIF_LISTEN_(@"NewOneGameGameListFailed",self,@selector(singleGameRequestFailed:),nil);
        [_SERVICES_ fetchOneGameGameList:_MODEL_.skipGameDetails];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewOneGameGameListFailed" object:nil];
    [self gamePickedForPlay:[n.userInfo objectForKey:@"game"]];
    _MODEL_.skipGameDetails = 0; // PHIL HATES THIS
}

- (void) singleGameRequestFailed:(NSNotification *)n
{
    [[ARISAlertHandler sharedAlertHandler] removeNetworkAlert];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewOneGameGameListReady" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewOneGameGameListFailed" object:nil];
    [self displayContentController:gamePickersViewController];
}

- (void) gamePickedForPlay:(Game *)g
{
    [[ARISPusherHandler sharedPusherHandler] loginGame:g.game_id]; 
    gamePlayViewController = [[GamePlayViewController alloc] initWithGame:g delegate:self];
    [self displayContentController:gamePlayViewController];
}

- (void) gameplayWasDismissed
{
    [[ARISPusherHandler sharedPusherHandler] logoutGame];  
    [self displayContentController:gamePickersViewController];
    gamePlayViewController = nil; 
    
    //PHIL HATES THIS CHUNK
    _MODEL_.fallbackGameId = 0;
    [_MODEL_ saveUserDefaults];
    //PHIL DONE HATING THIS CHUNK
}

- (void) logoutWasRequested
{
    [[ARISPusherHandler sharedPusherHandler] logoutPlayer];   
    _MODEL_PLAYER_ = nil;
    [_MODEL_ saveUserDefaults];
    [(LoginViewController *)[[loginNavigationController viewControllers] objectAtIndex:0] resetState];
    [self displayContentController:loginNavigationController];
}

@end
