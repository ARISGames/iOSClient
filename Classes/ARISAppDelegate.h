//
//  ARISAppDelegate.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright University of Wisconsin 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h";
#import "ToolbarViewController.h";
#import "GamePickerViewController.h";
#import "model/AppModel.h";
#import "MyCLController.h"
#import "TODOViewController.h"
#import "GenericWebViewController.h";

@interface ARISAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	LoginViewController *loginViewController;
	ToolbarViewController *toolbarViewController;
	GamePickerViewController *gamePickerViewController;
	AppModel *appModel;
	UIWebView *webView;
	MyCLController *myCLController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;
@property (nonatomic, retain) IBOutlet ToolbarViewController *toolbarViewController;
@property (nonatomic, retain) IBOutlet GamePickerViewController *gamePickerViewController;

@end
