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
	IBOutlet UIButton *cameraButton;
	IBOutlet UIButton *libraryButton;

    UIImagePickerController *imagePickerController;
}

@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *libraryButton;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

- (IBAction)cameraButtonTouchAction;
- (IBAction)libraryButtonTouchAction;


@end
