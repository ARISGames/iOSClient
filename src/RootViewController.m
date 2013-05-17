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

#import "LoginViewController.h"
#import "PlayerSettingsViewController.h"
#import "GamePickersViewController.h"
#import "GamePlayViewController.h"

#import "ARISNavigationController.h"

#import "AppServices.h"

@interface RootViewController () <UINavigationControllerDelegate, LoginViewControllerDelegate, PlayerSettingsViewControllerDelegate, GamePickersViewControllerDelegate, GamePlayViewControllerDelegate>
{
    ARISNavigationController *loginNavigationController;
    ARISNavigationController *playerSettingsViewNavigationController;
    GamePickersViewController *gamePickersViewController;
    GamePlayViewController *gamePlayViewController;
}

@property (nonatomic, strong) ARISNavigationController *loginNavigationController;
@property (nonatomic, strong) ARISNavigationController *playerSettingsNavigationController;
@property (nonatomic, strong) GamePickersViewController *gamePickersViewController;
@property (nonatomic, strong) GamePlayViewController *gamePlayViewController;

@end

@implementation RootViewController

@synthesize loginNavigationController;
@synthesize playerSettingsNavigationController;
@synthesize gamePickersViewController;
@synthesize gamePlayViewController;

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
        self.loginNavigationController = [[ARISNavigationController alloc] initWithRootViewController:loginViewController];
        self.loginNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        PlayerSettingsViewController *playerSettingsViewController = [[PlayerSettingsViewController alloc] initWithDelegate:self];
        self.playerSettingsNavigationController = [[ARISNavigationController alloc] initWithRootViewController:playerSettingsViewController];
        self.playerSettingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        self.gamePickersViewController = [[GamePickersViewController alloc] initWithDelegate:self];
        
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
        [self displayContentController:self.loginNavigationController];
}

- (void) loginCredentialsApprovedForPlayer:(Player *)p toGame:(int)gameId newPlayer:(BOOL)newPlayer disableLeaveGame:(BOOL)disableLeaveGame
{
    [[AppModel sharedAppModel] commitPlayerLogin:p];
    
    //PHIL HATES THIS NEXT CHUNK
    [AppModel sharedAppModel].disableLeaveGame = disableLeaveGame;
    if(newPlayer)
    {
        [(PlayerSettingsViewController *)self.playerSettingsNavigationController.topViewController resetState];
        [self displayContentController:self.playerSettingsNavigationController];
    }
    if(gameId)
    {
        [AppModel sharedAppModel].skipGameDetails = gameId;
        if(!newPlayer)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleGameRequestReady:) name:@"NewOneGameGameListReady" object:nil];
            [[AppServices sharedAppServices] fetchOneGameGameList:gameId];
        }
    }
    //PHIL DONE HATING CHUNK
    
    if(!newPlayer && !gameId)
        [self displayContentController:self.gamePickersViewController];
}

- (void) playerSettingsRequested
{
    //PHIL HATES THIS NEXT CHUNK
    [(PlayerSettingsViewController *)self.playerSettingsNavigationController.topViewController resetState];
    [self displayContentController:self.playerSettingsNavigationController];
    //PHIL DONE HATING CHUNK
}

- (void) playerSettingsWasDismissed
{
    //PHIL HATES THIS CHUNK
    if([AppModel sharedAppModel].skipGameDetails)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleGameRequestReady:) name:@"NewOneGameGameListReady" object:nil];
        [[AppServices sharedAppServices] fetchOneGameGameList:[AppModel sharedAppModel].skipGameDetails];
        [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:@"Confirming..."];
    }
    else
        [self displayContentController:self.gamePickersViewController];
    //PHIL DONE HATING THIS CHUNK
}

- (void) singleGameRequestReady:(NSNotification *)n
{
    [[ARISAlertHandler sharedAlertHandler] removeNetworkAlert];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewOneGameGameListReady" object:nil];
    [self gamePickedForPlay:[n.userInfo objectForKey:@"game"]];
    [AppModel sharedAppModel].skipGameDetails = 0; // PHIL HATES THIS
}

- (void) gamePickedForPlay:(Game *)g
{
    self.gamePlayViewController = [[GamePlayViewController alloc] initWithGame:g delegate:self];
    [self displayContentController:self.gamePlayViewController];
}

- (void) gameplayWasDismissed
{
    self.gamePlayViewController = nil;
    [self displayContentController:self.gamePickersViewController];
    
    //PHIL HATES THIS CHUNK
    [AppModel sharedAppModel].fallbackGameId = 0;
    [[AppModel sharedAppModel] saveUserDefaults];
    //PHIL DONE HATING THIS CHUNK
}

- (void) logoutWasRequested
{
    [AppModel sharedAppModel].player = nil;
    [[AppModel sharedAppModel] saveUserDefaults];
    [(LoginViewController *)[[self.loginNavigationController viewControllers] objectAtIndex:0] resetState];
    [self displayContentController:self.loginNavigationController];
}

@end
