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
    UIWindow *window;
    UITabBarController *tabBarController;
	LoginViewController *loginViewController;
	GamePickerViewController *gamePickerViewController;
	AppModel *appModel;
	UIWebView *webView;
	MyCLController *myCLController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet GamePickerViewController *gamePickerViewController;

@end
