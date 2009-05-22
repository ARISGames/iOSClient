//
//  ARISAppDelegate.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";

#import "LoginViewController.h";
#import "GenericWebViewController.h";
#import "MyCLController.h"

#import "model/Game.h"
#import "NearbyLocation.h"
#import "NearbyBar.h"
#import "Item.h"
#import "ItemDetailsViewController.h"

#import "QuestsViewController.h"
#import "GPSViewController.h"
#import "InventoryListViewController.h"
#import "CameraViewController.h"
#import "QRScannerViewController.h"
#import "IMViewController.h"
#import "GamePickerViewController.h"
#import "LogoutViewController.h"
#import "DeveloperViewController.h"

@interface ARISAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
	AppModel *appModel;
	UIWindow *window;
    UITabBarController *tabBarController;
	NearbyBar *nearbyBar;
	MyCLController *myCLController;
	LoginViewController *loginViewController;
	UINavigationController *loginViewNavigationController;
	GamePickerViewController *gamePickerViewController;
	UINavigationController *gamePickerNavigationController;
	UINavigationController *nearbyObjectNavigationController;
}

@property (nonatomic, retain) AppModel *appModel;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *loginViewNavigationController;
@property (nonatomic, retain) IBOutlet GamePickerViewController *gamePickerViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *gamePickerNavigationController;
@property (nonatomic, retain) IBOutlet NearbyBar *nearbyBar;
@property (nonatomic, retain) IBOutlet UINavigationController *nearbyObjectNavigationController;

- (void)displayNearbyObjectView:(UIViewController *)nearbyObjectViewController;

@end
