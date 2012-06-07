﻿//
//  ARISAppDelegate.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

#import "LoginViewController.h"
#import "MyCLController.h"

#import "model/Game.h"

#import "NearbyObjectsViewController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "Item.h"
#import "ItemDetailsViewController.h"
#import "QuestsViewController.h"
#import "GPSViewController.h"
#import "InventoryListViewController.h"
#import "AttributesViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "ARViewViewControler.h"
#import "QRScannerViewController.h"
#import "LogoutViewController.h"
#import "DeveloperViewController.h"
#import "WaitingIndicatorViewController.h"
#import "WaitingIndicatorView.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Reachability.h"
#import "TutorialViewController.h"
#import "NotebookViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "PTPusherDelegate.h"
#import "GamePickerNearbyViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "LoadingViewController.h"


@interface ARISAppDelegate : NSObject <AVAudioPlayerDelegate,UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate,PTPusherDelegate> {
	UIWindow *window;
    UITabBarController *tabBarController;
    UIViewController *defaultViewControllerForMainTabBar;
    UITabBarController *gameSelectionTabBarController;
    TutorialViewController *tutorialViewController;
	UINavigationController *nearbyObjectsNavigationController;
	LoginViewController *loginViewController;
	UINavigationController *loginViewNavigationController;
	UINavigationController *nearbyObjectNavigationController;
	WaitingIndicatorViewController *waitingIndicator;
	WaitingIndicatorView *waitingIndicatorView;

	LoadingViewController *loadingVC;
	UIAlertView *networkAlert;
	UIAlertView *serverAlert;
	TutorialPopupView *tutorialPopupView; 
	
	UIWindow* tvOutWindow;
	UIImageView *tvOutMirrorView;
	BOOL tvOutDone;
    BOOL modalPresent;
    NSInteger notificationCount;
    UILabel *titleLabel;
    UILabel *descLabel;
NSMutableArray *notifArray;
    int tabShowY;
    PTPusher *client;
 //   NSDictionary *imageInfo;
}
@property(readwrite,assign)int tabShowY;
@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) UIViewController *defaultViewControllerForMainTabBar;
@property (nonatomic) IBOutlet UITabBarController *gameSelectionTabBarController;
@property (nonatomic) IBOutlet TutorialViewController *tutorialViewController;
@property (nonatomic) IBOutlet LoginViewController *loginViewController;
@property (nonatomic) IBOutlet UINavigationController *loginViewNavigationController;
@property (nonatomic) IBOutlet UINavigationController *nearbyObjectsNavigationController;
@property (nonatomic) IBOutlet UINavigationController *nearbyObjectNavigationController;
@property (nonatomic) WaitingIndicatorViewController *waitingIndicator;
@property (nonatomic) WaitingIndicatorView *waitingIndicatorView;
@property(nonatomic)LoadingViewController *loadingVC;
@property(nonatomic) NSMutableArray *notifArray;
@property (nonatomic) UIAlertView *networkAlert;
@property (nonatomic) UIAlertView *serverAlert;
@property(nonatomic)PTPusher *pubClient;
@property(nonatomic)PTPusher *privClient;
//@property(nonatomic)NSDictionary *imageInfo;

@property (readwrite) BOOL modalPresent;
@property (readwrite) NSInteger notificationCount;

@property(nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic) IBOutlet UILabel *descLabel;

@property (nonatomic, strong) AVAudioPlayer *player;

- (void)attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password;
- (void) displayNearbyObjectView:(UIViewController *)nearbyObjectsNavigationController;
- (void) showWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)yesOrNo;
- (void) showNewWaitingIndicator:(NSString *)message displayProgressBar:(BOOL)displayProgressBar;
- (void) showServerAlertWithEmail:(NSString *)title message:(NSString *)message details:(NSString*)detail;
- (void) removeWaitingIndicator;
- (void) removeNewWaitingIndicator;
- (void) showNetworkAlert;
- (void) removeNetworkAlert;
- (void) showNearbyTab: (BOOL) yesOrNo;
- (void) returnToHomeView;
- (void) showGameSelectionTabBarAndHideOthers;
- (void) playAudioAlert:(NSString*)wavFileName shouldVibrate:(BOOL)shouldVibrate;
- (void) playAudioFromMedia:(Media*)media;
- (void) checkForDisplayCompleteNode;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void) displayIntroNode;
- (void) changeTabBar;
- (void) resetCurrentlyFetchingVars;
- (void) showNotifications;
- (void) hideNotifications;
- (void)dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController;
- (void) handleOpenURLGamesListReady;
@end
