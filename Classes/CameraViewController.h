//
//  CameraViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";


@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	AppModel *appModel;	
	IBOutlet UIButton *takePhotoButton;
	IBOutlet UIButton *uploadPhotoButton;
    IBOutlet UIImageView *image;
    UIImagePickerController *imagePickerController;
}
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

- (IBAction)cameraButtonTouchAction;

@end
