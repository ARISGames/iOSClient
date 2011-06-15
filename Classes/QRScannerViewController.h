//
//  QRScannerViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "DecoderDelegate.h"

@interface QRScannerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DecoderDelegate>{
	IBOutlet UIButton *qrScanButton;
    IBOutlet UIButton *imageScanButton;
	IBOutlet UITextField *manualCode;
    UIImagePickerController *qrImagePickerController;
    UIImagePickerController *imageMatchingImagePickerController;
}

@property (nonatomic, retain) IBOutlet UIButton *qrScanButton;
@property (nonatomic, retain) IBOutlet UIButton *imageScanButton;
@property (nonatomic, retain) IBOutlet UITextField *manualCode;
@property (nonatomic, retain) UIImagePickerController *qrImagePickerController;
@property (nonatomic, retain) UIImagePickerController *imageMatchingImagePickerController;


- (IBAction)qrScanButtonTouchAction: (id) sender;
- (IBAction)imageScanButtonTouchAction: (id) sender;
- (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode;
- (void) loadResult:(NSString *)result;


@end
