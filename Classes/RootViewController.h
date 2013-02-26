//
//  RootViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AudioToolbox/AudioToolbox.h"
#import "Reachability.h"
#import "PTPusherDelegate.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"

#import "MyCLController.h"

#import "ARViewViewControler.h"
#import "DeveloperViewController.h"
#import "WaitingIndicatorAlertViewController.h"

#import "TutorialViewController.h"
#import "LoadingViewController.h"

@interface RootViewController : UIViewController <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, PTPusherDelegate>
{
    TutorialViewController *tutorialViewController;

    UINavigationController *loginNavigationController;

    UITabBarController *gameSelectionTabBarController;
    UITabBarController *gamePlayTabBarController;
    
    UINavigationController *playerSettingsViewNavigationController;

    UINavigationController *nearbyObjectsNavigationController;
    UINavigationController *nearbyObjectNavigationController;
    
    LoadingViewController *loadingViewController;

	WaitingIndicatorAlertViewController *waitingIndicatorAlertViewController;
    UIAlertView *networkAlert;
	UIAlertView *serverAlert;
    
    PTPusher *pusherClient;
    //PTPusherPrivateChannel *playerChannel;
    //PTPusherPrivateChannel *groupChannel;
    PTPusherPrivateChannel *gameChannel;
    //PTPusherPrivateChannel *webpageChannel;

    BOOL usesIconQuestView;
}

@property (nonatomic) TutorialViewController *tutorialViewController;
@property (nonatomic) UINavigationController *loginNavigationController;

@property (nonatomic) UITabBarController *gameSelectionTabBarController;
@property (nonatomic) UITabBarController *gamePlayTabBarController;

@property (nonatomic) UINavigationController *playerSettingsNavigationController;

@property (nonatomic) UINavigationController *nearbyObjectsNavigationController;
@property (nonatomic) UINavigationController *nearbyObjectNavigationController;

@property (nonatomic) LoadingViewController *loadingViewController;

@property (nonatomic) WaitingIndicatorAlertViewController *waitingIndicatorAlertViewController;
@property (nonatomic) UIAlertView *networkAlert;
@property (nonatomic) UIAlertView *serverAlert;

@property (nonatomic, strong) PTPusher *pusherClient;
//@property (nonatomic) PTPusherPrivateChannel *playerChannel;
//@property (nonatomic) PTPusherPrivateChannel *groupChannel;
@property (nonatomic) PTPusherPrivateChannel *gameChannel;
//@property (nonatomic) PTPusherPrivateChannel *webpageChannel;

@property (readwrite) BOOL usesIconQuestView;

+ (RootViewController *)sharedRootViewController;

- (void) attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;
- (void) createUserAndLoginWithGroup:(NSString *)groupName andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;

- (void) changeTabBar;
- (void) showGameSelectionTabBarAndHideOthers;

- (void) selectGameWithoutPicker:(NSNotification *)notification;
- (void) selectGame:(NSNotification *)notification;

- (void) showNearbyTab:(BOOL)yesOrNo;
- (void) displayNearbyObjectView:(UIViewController *)nearbyObjectViewController;
- (void) dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController;

- (void) beginGamePlay;
- (void) checkForDisplayCompleteNode;

- (void) showAlert:(NSString *)title message:(NSString *)message;
- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail;

- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar;
- (void) removeWaitingIndicator;

- (void) showNetworkAlert;
- (void) removeNetworkAlert;

//- (void) didReceivePlayerChannelEventNotification:(NSNotification *)notification;
//- (void) didReceiveGroupChannelEventNotification:(NSNotification *)notification;
- (void) didReceiveGameChannelEventNotification:(NSNotification *)notification;
//- (void) didReceiveWebpageChannelEventNotification:(NSNotification *)notification;

@end