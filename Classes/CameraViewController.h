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
    id backView, parentDelegate, editView;
    int noteId;
    BOOL bringUpCamera;
    UIImagePickerController *picker;
}

@property (nonatomic) IBOutlet UIButton *cameraButton;
@property (nonatomic) IBOutlet UIButton *profileButton;
@property (nonatomic) IBOutlet UIButton *libraryButton;
//@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic) NSData *mediaData;
@property (nonatomic) NSString *mediaFilename;
@property (nonatomic) id backView;
@property (nonatomic) id parentDelegate;
@property (nonatomic) id editView;
@property(nonatomic)UIImagePickerController *picker;

@property(readwrite,assign) BOOL showVid;
@property(readwrite,assign) int noteId;


- (IBAction)cameraButtonTouchAction;
- (IBAction)libraryButtonTouchAction;
- (IBAction)profileButtonTouchAction;
//- (BOOL) isVideoCameraAvailable;
-(void) uploadMedia;
- (NSMutableData*)dataWithEXIFUsingData:(NSData*)originalJPEGData;
@end
