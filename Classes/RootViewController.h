//
//  RootViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define SCREEN_HEIGHT 480
#define SCREEN_WIDTH 320
#define STATUS_BAR_HEIGHT 20
#define NOTIFICATION_HEIGHT 40
#define TRUE_ZERO_Y -20

#import <UIKit/UIKit.h>
#import "AppModel.h"

#import "LoginViewController.h"
#import "MyCLController.h"

#import "model/Game.h"

#import "NearbyObjectsViewController.h"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "Item.h"
#import "Location.h"
#import "ItemDetailsViewController.h"
#import "QuestsViewController.h"
#import "IconQuestsViewController.h"
#import "GPSViewController.h"
#import "InventoryListViewController.h"
#import "AttributesViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "ARViewViewControler.h"
#import "QRScannerViewController.h"
#import "LogoutViewController.h"
#import "GlobalPlayerViewController.h"
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

@interface RootViewController : UIViewController<UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate,PTPusherDelegate> {
    UITabBarController *tabBarController;
    UIViewController *defaultViewControllerForMainTabBar;
    UITabBarController *gameSelectionTabBarController;
    TutorialViewController *tutorialViewController;
	UINavigationController *nearbyObjectsNavigationController;
	LoginViewController *loginViewController;
	UINavigationController *loginViewNavigationController;
    GlobalPlayerViewController *globalPlayerViewController;
    UINavigationController *globalPlayerViewNavigationController;
	UINavigationController *nearbyObjectNavigationController;
	WaitingIndicatorViewController *waitingIndicator;
	WaitingIndicatorView *waitingIndicatorView;
    
	LoadingViewController *loadingVC;
	UIAlertView *networkAlert;
	UIAlertView *serverAlert;
	TutorialPopupView *tutorialPopupView;
	
    BOOL modalPresent;
    BOOL isMovie;
    BOOL isItemDetailsMovie; 
    UILabel *titleLabel;
    UILabel *descLabel;
    CGRect squishedVCFrame;
    CGRect notSquishedVCFrame;
    NSMutableArray *notifArray;
    //int notificationBarHeight;
    PTPusher *client;
    //   NSDictionary *imageInfo;
}
//@property(readwrite,assign)int notificationBarHeight;
@property (nonatomic) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) UIViewController *defaultViewControllerForMainTabBar;
@property (nonatomic) IBOutlet UITabBarController *gameSelectionTabBarController;
@property (nonatomic) IBOutlet TutorialViewController *tutorialViewController;
@property (nonatomic) IBOutlet LoginViewController *loginViewController;
@property (nonatomic) IBOutlet UINavigationController *loginViewNavigationController;
@property (nonatomic) IBOutlet GlobalPlayerViewController *globalPlayerViewController;
@property (nonatomic) IBOutlet UINavigationController *globalPlayerViewNavigationController;
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
@property (readwrite) BOOL isMovie;
@property (readwrite) BOOL isItemDetailsMovie;

@property(nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic) IBOutlet UILabel *descLabel;
@property(nonatomic) CGRect notSquishedVCFrame;
@property(nonatomic) CGRect squishedVCFrame;

+ (RootViewController *)sharedRootViewController;

- (void)selectGame:(NSNotification *)notification;
- (void) attemptLoginWithUserName:(NSString *)userName andPassword:(NSString *)password andGameId:(int)gameId inMuseumMode:(BOOL)museumMode;
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
- (void) checkForDisplayCompleteNode;
- (void) displayIntroNode;
- (void) changeTabBar;
- (void) enqueueNotificationWithTitle:(NSString *)title andPrompt:(NSString *)prompt;
- (void) showNotifications;
- (void) hideNotifications;
- (void) dismissNearbyObjectView:(UIViewController *)nearbyObjectViewController;
- (void) handleOpenURLGamesListReady;
- (void) showAlert:(NSString *)title message:(NSString *)message;
@end
