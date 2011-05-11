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

@interface QRScannerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DecoderDelegate> {
	IBOutlet UIButton *scanButton;
	IBOutlet UITextField *manualCode;
    UIImagePickerController *imagePickerController;
}


- (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode;

@property (nonatomic, retain) IBOutlet UIButton *scanButton;
@property (nonatomic, retain) IBOutlet UITextField *manualCode;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;


- (IBAction)scanButtonTouchAction: (id) sender;

-(void) loadResult:(NSString *)result;


@end
