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
#import "LoadingViewController.h"
#import "GamePlayViewController.h"

#import "ARISNavigationController.h"

#import "AppServices.h"

@interface RootViewController () <UINavigationControllerDelegate, LoginViewControllerDelegate, PlayerSettingsViewControllerDelegate, GamePickersViewControllerDelegate, LoadingViewControllerDelegate, GamePlayViewControllerDelegate>
{
    ARISNavigationController *loginNavigationController;
    ARISNavigationController *playerSettingsNavigationController;
    GamePickersViewController *gamePickersViewController;
    LoadingViewController *loadingViewController; 
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
        
        loadingViewController = [[LoadingViewController alloc] initWithDelegate:self];
        
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_IN",self,@selector(playerLoggedIn),nil); 
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_OUT",self,@selector(playerLoggedOut),nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_CHOSEN",self,@selector(gameChosen),nil); 
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_BEGAN",self,@selector(gameBegan),nil);  
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_LEFT",self,@selector(gameLeft),nil);   
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
    if(false)//!_MODEL_PLAYER_.display_name || !_MODEL_PLAYER_.media_id)
        [self displayContentController:playerSettingsNavigationController];
    else if(!_MODEL_GAME_)
        [self displayContentController:gamePickersViewController]; 
    else if(gamePlayViewController)
        [self displayContentController:gamePlayViewController];  
}

- (void) gameChosen
{
    [self displayContentController:loadingViewController];
}

- (void) gameBegan
{
    [self displayContentController:gamePlayViewController]; 
}

- (void) gameLeft
{
    [self displayContentController:gamePickersViewController]; 
}

- (void) profileEditRequested
{
    [(PlayerSettingsViewController *)playerSettingsNavigationController.topViewController resetState];
    [self displayContentController:playerSettingsNavigationController];   
}

- (void) playerSettingsWasDismissed
{
    if(!_MODEL_GAME_)
        [self displayContentController:gamePickersViewController]; 
    else if(gamePlayViewController)
        [self displayContentController:gamePlayViewController];   
}

@end
