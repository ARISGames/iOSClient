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

@interface PlayerSettingsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AsyncMediaImageViewDelegate, UITextFieldDelegate> {
	IBOutlet AsyncMediaImageView *playerPic;
    IBOutlet UITextField *playerNameField;
	IBOutlet UIButton *playerPicCamButton;
    IBOutlet UIButton *saveButton;
}

@property (nonatomic) IBOutlet AsyncMediaImageView *playerPic;
@property (nonatomic) IBOutlet UITextField *playerNameField;
@property (nonatomic) IBOutlet UIButton *playerPicCamButton;
@property (nonatomic) IBOutlet UIButton *saveButton;

- (id)initWithDelegate:(id<PlayerSettingsViewControllerDelegate>)d;
-(void)viewDidIntentionallyAppear;
-(void) refreshViewFromModel;
-(IBAction)saveButtonTouched:(id)sender;
-(IBAction)playerPicCamButtonTouched:(id)sender;

@end
