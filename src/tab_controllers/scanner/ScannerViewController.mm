//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ScannerViewController.h"
//#import <ZXingWidgetController.h>
//#import "Decoder.h"
#import <AVFoundation/AVFoundation.h>
#import "ARISAppDelegate.h"
#import "AppModel.h"
//#import "QRCodeReader.h"
#import "ARISAlertHandler.h"

@interface ScannerViewController() <AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate>
{
    Tab *tab;
    NSString *prompt;
    NSDate *lastError;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    BOOL scanning;
    id<ScannerViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation ScannerViewController

- (id) initWithTab:(Tab *)t delegate:(id<ScannerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tab = t;
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");

        lastError = [NSDate date];
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
}


- (void) viewWillAppearFirstTime:(BOOL)animated
{
    [super viewWillAppearFirstTime:animated];

    //overwrite the nav button written by superview so we can listen for touchDOWN events as well (to dismiss camera)
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"In-Game Menu";
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

    [session stopRunning];
    scanning = NO;
}


- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}


-  (void) setPrompt:(NSString *)p
{
    prompt = p;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if(scanning)
    {
        BOOL not_found = NO;

        for (AVMetadataObject *metadata in metadataObjects)
        {
            scanning = NO;

            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[previewLayer transformedMetadataObjectForMetadataObject:metadata];
            NSString *result = [transformed stringValue];

            Trigger *t;
            if([result isEqualToString:@"log-out"])
            {
                [_MODEL_ logOut];

                // Leave after successful scan
                return;
            }
            else
            {
                t = [_MODEL_TRIGGERS_ triggerForQRCode:result];

                if(!t)
                {
                    not_found = YES;
                }
                else
                {
                    [_MODEL_DISPLAY_QUEUE_ enqueueTrigger:t];

                    // Leave after successful scan
                    return;
                }
            }

        }

        // All metadata visible scanned
        if(not_found)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", nil) message:NSLocalizedString(@"QRScannerErrorMessageKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
            [alert show];
        }
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    scanning = YES;
}


//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"SCANNER"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return @"Scanner"; }
- (UIImage *) tabIcon { return [UIImage imageNamed:@"qr_icon"]; }

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
