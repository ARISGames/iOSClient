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
	IBOutlet UIButton *scanButton;
	IBOutlet UITextField *manualCode;
    UIImagePickerController *imagePickerController;
}


- (void) setModel:(AppModel *)model;
- (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode;

@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) IBOutlet UIButton *scanButton;
@property (nonatomic, retain) IBOutlet UITextField *manualCode;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;


- (IBAction)scanButtonTouchAction: (id) sender;
- (IBAction)codeEnteredAction: (id) sender;

-(void) loadResult:(NSString *)result;


@end
