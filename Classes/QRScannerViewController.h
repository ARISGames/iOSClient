//
//  QRScannerViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";


@interface QRScannerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	NSString *moduleName;
	AppModel *appModel;
	UIButton *scanButton;
    UIImagePickerController *imagePickerController;
}


- (void) setModel:(AppModel *)model;

@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) UIButton *scanButton;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;


- (IBAction)scanButtonTouchAction: (id) sender;


@end
