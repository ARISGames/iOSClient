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

#import "GameObjectDisplayViewController.h"
#import "GameNotificationViewController.h"
#import "BogusSelectGameViewController.h"

#import "MyCLController.h"

#import "ARViewViewControler.h"
#import "DeveloperViewController.h"
#import "WaitingIndicatorAlertViewController.h"

#import "TutorialViewController.h"

@interface RootViewController : UIViewController <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, PTPusherDelegate>
{
    GameNotificationViewController *gameNotificationViewController;
    GameObjectDisplayViewController *gameObjectDisplayViewController;
    
    NSString *errorMessage;
    NSString *errorDetail;
    
    TutorialViewController *tutorialViewController;

    UINavigationController *loginNavigationController;

    UITabBarController *gamePickerTabBarController;
    UITabBarController *gamePlayTabBarController;
    
    UINavigationController *playerSettingsViewNavigationController;

    UINavigationController *nearbyObjectsNavigationController;
    UINavigationController *nearbyObjectNavigationController;
    //UINavigationController *arNavigationController;        
    UINavigationController *questsNavigationController;
    UINavigationController *iconQuestsNavigationController;
    UINavigationController *gpsNavigationController;
    UINavigationController *inventoryNavigationController;
    UINavigationController *attributesNavigationController;
    UINavigationController *notesNavigationController;
    UINavigationController *decoderNavigationController;
    BogusSelectGameViewController *bogusSelectGameViewController;
    
	WaitingIndicatorAlertViewController *waitingIndicatorAlertViewController;
    UIAlertView *networkAlert;
	UIAlertView *serverAlert;
    
    PTPusher *pusherClient;
    //PTPusherPrivateChannel *playerChannel;
    //PTPusherPrivateChannel *groupChannel;
    PTPusherPrivateChannel *gameChannel;
    //PTPusherPrivateChannel *webpageChannel;
}

@property (nonatomic, strong) TutorialViewController *tutorialViewController;
@property (nonatomic, strong) UINavigationController *loginNavigationController;

@property (nonatomic, strong) UITabBarController *gamePickerTabBarController;
@property (nonatomic, strong) UITabBarController *gamePlayTabBarController;

@property (nonatomic, strong) UINavigationController *playerSettingsNavigationController;

@property (nonatomic, strong) UINavigationController *nearbyObjectsNavigationController;
@property (nonatomic, strong) UINavigationController *nearbyObjectNavigationController;
//@property (nonatomic, strong) UINavigationController *arNavigationController;
@property (nonatomic, strong) UINavigationController *questsNavigationController;
@property (nonatomic, strong) UINavigationController *iconQuestsNavigationController;
@property (nonatomic, strong) UINavigationController *gpsNavigationController;
@property (nonatomic, strong) UINavigationController *inventoryNavigationController;
@property (nonatomic, strong) UINavigationController *attributesNavigationController;
@property (nonatomic, strong) UINavigationController *notesNavigationController;
@property (nonatomic, strong) UINavigationController *decoderNavigationController;
@property (nonatomic, strong) BogusSelectGameViewController *bogusSelectGameViewController;

@property (nonatomic) WaitingIndicatorAlertViewController *waitingIndicatorAlertViewController;
@property (nonatomic) UIAlertView *networkAlert;
@property (nonatomic) UIAlertView *serverAlert;

@property (nonatomic, strong) PTPusher *pusherClient;
//@property (nonatomic) PTPusherPrivateChannel *playerChannel;
//@property (nonatomic) PTPusherPrivateChannel *groupChannel;
@property (nonatomic) PTPusherPrivateChannel *gameChannel;
//@property (nonatomic) PTPusherPrivateChannel *webpageChannel;

+ (RootViewController *)sharedRootViewController;

- (void)attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;
- (void)createUserAndLoginWithGroup:(NSString *)groupName andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;

- (void)setGamePlayTabBarVCs:(NSArray *)gamePlayTabs;
- (void)showGamePickerTabBarAndHideOthers;

- (void)selectGameWithoutPicker:(NSNotification *)notification;
- (void)commitToPlayGame:(NSNotification *)notification;

- (void)showNearbyTab:(BOOL)yesOrNo;
- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController;
- (void)dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController;

- (void)beginGamePlay;
- (void)checkForDisplayCompleteNode;

- (void)showAlert:(NSString *)title message:(NSString *)message;
- (void)showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail;

- (void)showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar;
- (void)removeWaitingIndicator;

- (void)showNetworkAlert;
- (void)removeNetworkAlert;

//- (void)didReceivePlayerChannelEventNotification:(NSNotification *)notification;
//- (void)didReceiveGroupChannelEventNotification:(NSNotification *)notification;
- (void)didReceiveGameChannelEventNotification:(NSNotification *)notification;
//- (void)didReceiveWebpageChannelEventNotification:(NSNotification *)notification;

@end
