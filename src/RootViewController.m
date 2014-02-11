//
//  RootViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"

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
        LoginViewController* loginViewController = [[LoginViewController alloc] initWithDelegate:self];
        loginNavigationController = [[ARISNavigationController alloc] initWithRootViewController:loginViewController];
        
        PlayerSettingsViewController *playerSettingsViewController = [[PlayerSettingsViewController alloc] initWithDelegate:self];
        playerSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:playerSettingsViewController];
        
        //PHIL HATES THIS
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutWasRequested) name:@"LogoutRequested" object:nil];
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

- (void) loginCredentialsApprovedForPlayer:(Player *)p toGame:(int)gameId newPlayer:(BOOL)newPlayer disableLeaveGame:(BOOL)disableLeaveGame
{
    [[AppModel sharedAppModel] commitPlayerLogin:p];
    //[[ARISPusherHandler sharedPusherHandler] loginPlayer:p.playerId];
    
    //PHIL HATES THIS NEXT CHUNK
    [AppModel sharedAppModel].disableLeaveGame = disableLeaveGame;
    if(newPlayer)
    {
        [(PlayerSettingsViewController *)playerSettingsNavigationController.topViewController resetState];
        [self displayContentController:playerSettingsNavigationController];
    }
    if(gameId)
    {
        [AppModel sharedAppModel].skipGameDetails = gameId;
        if(!newPlayer)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleGameRequestReady:)  name:@"NewOneGameGameListReady"  object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleGameRequestFailed:) name:@"NewOneGameGameListFailed" object:nil];
            [[AppServices sharedAppServices] fetchOneGameGameList:gameId];
        }
    }
    //PHIL DONE HATING CHUNK
    
    gamePickersViewController = [[GamePickersViewController alloc] initWithDelegate:self];
    
    if(!newPlayer && !gameId)
        [self displayContentController:gamePickersViewController];
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
    if([AppModel sharedAppModel].skipGameDetails)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleGameRequestReady:)  name:@"NewOneGameGameListReady"  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleGameRequestFailed:) name:@"NewOneGameGameListFailed" object:nil];
        [[AppServices sharedAppServices] fetchOneGameGameList:[AppModel sharedAppModel].skipGameDetails];
        [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:@"Confirming..."];
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
    [AppModel sharedAppModel].skipGameDetails = 0; // PHIL HATES THIS
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
    [[ARISPusherHandler sharedPusherHandler] loginGame:g.gameId]; 
    gamePlayViewController = [[GamePlayViewController alloc] initWithGame:g delegate:self];
    [self displayContentController:gamePlayViewController];
}

- (void) gameplayWasDismissed
{
    [[ARISPusherHandler sharedPusherHandler] logoutGame];  
    [self displayContentController:gamePickersViewController];
    gamePlayViewController = nil; 
    
    //PHIL HATES THIS CHUNK
    [AppModel sharedAppModel].fallbackGameId = 0;
    [[AppModel sharedAppModel] saveUserDefaults];
    //PHIL DONE HATING THIS CHUNK
}

- (void) logoutWasRequested
{
    [[ARISPusherHandler sharedPusherHandler] logoutPlayer];   
    [AppModel sharedAppModel].player = nil;
    [[AppModel sharedAppModel] saveUserDefaults];
    [(LoginViewController *)[[loginNavigationController viewControllers] objectAtIndex:0] resetState];
    [self displayContentController:loginNavigationController];
}

@end
