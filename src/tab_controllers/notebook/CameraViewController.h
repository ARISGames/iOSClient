//
//  CameraViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    BOOL showVid;
    id backView;
    id parentDelegate;
    id editView;
    int noteId;
    BOOL bringUpCamera;
    UIImagePickerController *picker;
}

@property (nonatomic) id backView;
@property (nonatomic) id parentDelegate;
@property (nonatomic) id editView;
@property(nonatomic)UIImagePickerController *picker;

@property(readwrite,assign) BOOL showVid;
@property(readwrite,assign) int noteId;

- (NSMutableData*)dataWithEXIFUsingData:(NSData*)originalJPEGData;

@end
