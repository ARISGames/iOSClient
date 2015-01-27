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
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    BOOL scanning;
    id<LoginScannerViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation LoginScannerViewController

- (id) initWithDelegate:(id<LoginScannerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"LoginScannerTitleKey", @"");

        prompt = @"";

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
    scanning = NO;

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
    promptLabel.frame = CGRectMake(0, self.view.bounds.size.height-75,self.view.bounds.size.width,75);
    promptLabel.numberOfLines = 0;
    promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.textColor       = [UIColor ARISColorLightGray];
    promptLabel.backgroundColor = [UIColor ARISColorTranslucentBlack];
    [self.view addSubview:promptLabel];
    [self setPrompt:prompt];

}


- (void) viewWillAppearFirstTime:(BOOL)animated
{
    [super viewWillAppearFirstTime:animated];

    //overwrite the nav button written by superview so we can listen for touchDOWN events as well (to dismiss camera)
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(cancelScanner) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"Back";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [session startRunning];
    scanning = YES;
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self setPrompt: @""];
    [session stopRunning];
    scanning = NO;
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
    [delegate captureOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection];
/*
    if(scanning)
    {
        if (metadataObjects != nil && [metadataObjects count] > 0)
        {
            BOOL not_found = NO;
            scanning = NO;

            for (AVMetadataObject *metadata in metadataObjects)
            {

                AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[previewLayer transformedMetadataObjectForMetadataObject:metadata];
                NSString *result = [transformed stringValue];

                not_found = YES;
            }

            // All metadata visible scanned
            if(not_found)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", nil) message:NSLocalizedString(@"QRScannerErrorMessageKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    */
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    scanning = YES;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

