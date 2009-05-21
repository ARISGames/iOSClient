//
//  QRScannerViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h"
#import "DecoderDelegate.h"
#import "QRScannerParserDelegate.h"
#import "GenericWebViewController.h"


@interface QRScannerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DecoderDelegate, QRScannerParserDelegateDelegate> {
	NSString *moduleName;
	AppModel *appModel;
	UIButton *scanButton;
    UIImagePickerController *imagePickerController;
}


- (void) setModel:(AppModel *)model;
- (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode;

@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) UIButton *scanButton;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;


- (IBAction)scanButtonTouchAction: (id) sender;


@end
