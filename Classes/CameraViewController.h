//
//  CameraViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";


@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	AppModel *appModel;	
	IBOutlet UIButton *cameraButton;
	IBOutlet UIButton *libraryButton;

    UIImagePickerController *imagePickerController;
	NSData *mediaData;
	NSString *mediaFilename;
}

@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *libraryButton;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, retain) NSString *mediaFilename;



- (IBAction)cameraButtonTouchAction;
- (IBAction)libraryButtonTouchAction;


@end
