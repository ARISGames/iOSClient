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
	NSString *moduleName;
	AppModel *appModel;
	
	IBOutlet UIButton *takePhotoButton;
	IBOutlet UIButton *uploadPhotoButton;
    IBOutlet UIImageView *image;
    UIImagePickerController *imagePickerController;
}


- (void) setModel:(AppModel *)model;
- (IBAction)cameraButtonTouchAction;
- (IBAction)uploadButtonTouchAction;

@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;


@end
