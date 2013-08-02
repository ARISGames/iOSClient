//
//  DecoderViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingWidgetController.h>
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"

@protocol StateControllerProtocol;

@protocol DecoderViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface DecoderViewController : ARISGamePlayTabBarViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ZXingDelegate>
{
	IBOutlet UITextField *manualCode;
    NSString *resultText;
    UIBarButtonItem *cancelButton;
}

@property (nonatomic) IBOutlet UITextField *manualCode;
@property (nonatomic) NSString *resultText;
@property (nonatomic) UIBarButtonItem *cancelButton;

- (id) initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d;
- (void) launchScannerWithPrompt:(NSString *)p;
- (IBAction) scanButtonTapped;
- (void) cancelButtonTouch;
- (void) loadResult:(NSString *)result;

@end
