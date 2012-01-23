//
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
#import "StartOverViewController.h"
#import "DeveloperViewController.h"
#import "WaitingIndicatorViewController.h"
#import "WaitingIndicatorView.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Reachability.h"
#import "TutorialViewController.h"
#import "NotebookViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

#import "GamePickerNearbyViewController.h"


@interface ARISAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
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

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UIViewController *defaultViewControllerForMainTabBar;
@property (nonatomic, retain) IBOutlet UITabBarController *gameSelectionTabBarController;
@property (nonatomic, retain) IBOutlet TutorialViewController *tutorialViewController;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *loginViewNavigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *nearbyObjectsNavigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *nearbyObjectNavigationController;
@property (nonatomic, retain) WaitingIndicatorViewController *waitingIndicator;
@property (nonatomic, retain) WaitingIndicatorView *waitingIndicatorView;

@property (nonatomic, retain) UIAlertView *networkAlert;
@property (nonatomic, retain) UIAlertView *serverAlert;

@property (readwrite) BOOL modalPresent;
@property (readwrite) NSInteger notificationCount;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *descLabel;


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
- (void) checkForDisplayCompleteNode;
- (void) displayIntroNode;
- (void) displayNotificationTitle:(NSDictionary *) titleAndPrompt;
- (void) changeNavColor: (NSDictionary *) navBarAndColorDict;
- (void) changeNavTitle: (NSDictionary *) navBarTitleAndPromptDict;
- (void) decrementNotificationCount: (NSDictionary *) navBarDict; 
- (void) changeTabBar;
- (void) resetCurrentlyFetchingVars;
@end
