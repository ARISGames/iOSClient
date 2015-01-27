//
//  LoginScannerViewController.h
//  ARIS
//
//  Created by Kevin Alford 1/25/15.

#import "ARISViewController.h"
#import <AVFoundation/AVFoundation.h>

@protocol LoginScannerViewControllerDelegate <AVCaptureMetadataOutputObjectsDelegate>
- (void) cancelLoginScan;

- (void) captureLoginScannerOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;
@end

@class Tab;
@interface LoginScannerViewController : ARISViewController
- (id) initWithDelegate:(id<LoginScannerViewControllerDelegate>)d;
@end
