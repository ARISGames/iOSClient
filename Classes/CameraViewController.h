//
//  CameraViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"


@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	IBOutlet UIButton *cameraButton;
	IBOutlet UIButton *libraryButton;
    IBOutlet UIButton *profileButton;

 //   UIImagePickerController *imagePickerController;
	NSData *mediaData;
	NSString *mediaFilename;
    BOOL showVid;
    id backView, parentDelegate,editView;
    int noteId;
    BOOL bringUpCamera;
}

@property (nonatomic, retain) IBOutlet UIButton *cameraButton;
@property (nonatomic, retain) IBOutlet UIButton *profileButton;
@property (nonatomic, retain) IBOutlet UIButton *libraryButton;
//@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) NSData *mediaData;
@property (nonatomic, retain) NSString *mediaFilename;
@property (nonatomic, assign) id backView;
@property (nonatomic, assign) id parentDelegate;
@property (nonatomic, assign) id editView;


@property(readwrite,assign) BOOL showVid;
@property(readwrite,assign) int noteId;


- (IBAction)cameraButtonTouchAction;
- (IBAction)libraryButtonTouchAction;
- (IBAction)profileButtonTouchAction;
//- (BOOL) isVideoCameraAvailable;
-(void) uploadMedia;
@end
