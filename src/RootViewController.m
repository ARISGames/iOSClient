//
//  RootViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> //for check if camera available

#import "RootViewController.h"

#import "AppModel.h"
#import "ARISAlertHandler.h"

#import "LoginViewController.h"
#import "PlayerSettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "GamePickersViewController.h"
#import "GameDetailsViewController.h"
#import "LoadingViewController.h"
#import "GamePlayViewController.h"

#import "ARISNavigationController.h"

@interface RootViewController () <UINavigationControllerDelegate, LoginViewControllerDelegate, PlayerSettingsViewControllerDelegate, ChangePasswordViewControllerDelegate, GamePickersViewControllerDelegate, GameDetailsViewControllerDelegate, LoadingViewControllerDelegate, GamePlayViewControllerDelegate>
{
  ARISNavigationController *loginNavigationController;
  ARISNavigationController *playerSettingsNavigationController;
  ARISNavigationController *changePasswordNavigationController;
  GamePickersViewController *gamePickersViewController;
  ARISNavigationController *gameDetailsNavigationController;
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

    changePasswordNavigationController =
      [[ARISNavigationController alloc] initWithRootViewController:
      [[ChangePasswordViewController alloc] initWithDelegate:self]
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
  else if(!currentChildViewController || currentChildViewController == loginNavigationController)
  {
    if(!_MODEL_GAME_)
      [self displayContentController:gamePickersViewController];
  }
}

- (void) playerLoggedOut
{
  if(gamePlayViewController) [gamePlayViewController destroy];
  gamePlayViewController = nil;
  [self displayContentController:loginNavigationController];
}

- (void) playerLoggedIn
{
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

  if((status != AVAuthorizationStatusDenied && status != AVAuthorizationStatusRestricted) &&
      _MODEL_.auto_profile_enabled && (!_MODEL_PLAYER_.display_name || !_MODEL_PLAYER_.media_id))
    [self displayContentController:playerSettingsNavigationController];
  else if(!_MODEL_GAME_)
  {
    [self displayContentController:gamePickersViewController];
    if(_MODEL_.preferred_game_id)
      [self performSelector:@selector(choosePreferredGame) withObject:nil afterDelay:0.1];
  }
  else if(gamePlayViewController)
    [self displayContentController:gamePlayViewController];
}

- (void) gameChosen
{
  [self displayContentController:loadingViewController];
  [loadingViewController startLoading];
}

- (void) gameBegan
{
  gamePlayViewController = [[GamePlayViewController alloc] initWithDelegate:self];
  [self displayContentController:gamePlayViewController];
}

- (void) gameLeft
{
  [self displayContentController:gamePickersViewController];
  if(gamePlayViewController) [gamePlayViewController destroy];
  gamePlayViewController = nil; //immediately dealloc
}

- (void) gameDetailsRequested:(Game *)g
{
  gameDetailsNavigationController =
    [[ARISNavigationController alloc] initWithRootViewController:
    [[GameDetailsViewController alloc] initWithGame:g delegate:self]
    ];
  [self displayContentController:gameDetailsNavigationController];
}

- (void) gameDetailsCanceled:(Game *)g
{
  [self displayContentController:gamePickersViewController];
  gameDetailsNavigationController = nil;
}

- (void) profileEditRequested
{
  [(PlayerSettingsViewController *)playerSettingsNavigationController.topViewController resetState];
  [self displayContentController:playerSettingsNavigationController];
}

- (void) passChangeRequested
{
  [self displayContentController:changePasswordNavigationController];
}

- (void) playerSettingsWasDismissed
{
  if(!_MODEL_GAME_)
  {
    [self displayContentController:gamePickersViewController];
    if(_MODEL_.preferred_game_id)
      [self performSelector:@selector(choosePreferredGame) withObject:nil afterDelay:0.1];
  }
  else if(gamePlayViewController)
    [self displayContentController:gamePlayViewController];
}

- (void) changePasswordWasDismissed
{
  if(!_MODEL_GAME_)
    [self displayContentController:gamePickersViewController];
  else if(gamePlayViewController)
    [self displayContentController:gamePlayViewController];
}

- (void) choosePreferredGame
{
  Game *g = [[Game alloc] init];
  g.game_id = _MODEL_.preferred_game_id;
  [_MODEL_ chooseGame:g];
}

@end
