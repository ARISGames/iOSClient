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


-(void)manuallyForceViewDidAppear;
-(void) refreshViewFromModel;
-(IBAction)playerNameFieldTouched:(id)sender;
-(IBAction)saveButtonTouched:(id)sender;
-(IBAction)playerPicCamButtonTouched:(id)sender;

@end
