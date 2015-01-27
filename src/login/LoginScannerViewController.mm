//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "LoginScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "ARISAlertHandler.h"

@interface LoginScannerViewController() <AVCaptureMetadataOutputObjectsDelegate>
{
    NSString *prompt;
    UILabel *promptLabel;
    UIButton *cancelButton;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    id<LoginScannerViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation LoginScannerViewController

- (id) initWithDelegate:(id<LoginScannerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"LoginScannerTitleKey", @"");

        prompt = @"Scan Login Code";

        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorBlack];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    [self loadAVMetadataScanner];
}


- (void) loadAVMetadataScanner
{
    // Create a new AVCaptureSession
    session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;

    // Want the normal device
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    if(input) {
        // Add the input to the session
        [session addInput:input];
    } else {
        NSLog(@"error: %@", error);
        return;
    }

    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];

    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode]];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    // Display on screen
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.bounds = self.view.bounds;
    previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:previewLayer];

    [session stopRunning];


    // Add QR overlay
    UIImageView *qr_overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr"]];
    qr_overlay.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.width);
    qr_overlay.alpha = 0.35;
    qr_overlay.center = CGPointMake( self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview:qr_overlay];

    // Add Prompt
    promptLabel = [[UILabel alloc] init];
    promptLabel.frame = CGRectMake(0, 0,self.view.bounds.size.width,75);
    promptLabel.numberOfLines = 0;
    promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.textColor       = [UIColor ARISColorLightGray];
    promptLabel.backgroundColor = [UIColor ARISColorTranslucentBlack];
    [self.view addSubview:promptLabel];
    [self setPrompt:prompt];

    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:NSLocalizedString(@"CancelKey", nil) forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor ARISColorRed]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [ARISTemplate ARISButtonFont];
    [cancelButton addTarget:self action:@selector(cancelLoginScan) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40);

    [self.view addSubview:cancelButton];

}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [session startRunning];
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self setPrompt: @""];
    [session stopRunning];
}

-  (void) setPrompt:(NSString *)p
{
    prompt = p;
    promptLabel.text = prompt;

    if([prompt isEqualToString:@""])
    {
      promptLabel.hidden = YES;
    }
    else
    {
      promptLabel.hidden = NO;
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
  [delegate captureLoginScannerOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection previewLayer:previewLayer];
}

- (void) cancelLoginScan
{
  [delegate cancelLoginScan];
}


- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

