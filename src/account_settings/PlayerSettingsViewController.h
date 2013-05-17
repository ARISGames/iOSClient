//
//  PlayerSettingsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "CameraViewController.h"
#import "AsyncMediaTouchableImageView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIImage+Scale.h"
#import <ImageIO/ImageIO.h>

@protocol PlayerSettingsViewControllerDelegate
- (void) playerSettingsWasDismissed;
@end

@interface PlayerSettingsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AsyncMediaImageViewDelegate, UITextFieldDelegate>

- (id)initWithDelegate:(id<PlayerSettingsViewControllerDelegate>)d;
- (void) resetState;

@end
