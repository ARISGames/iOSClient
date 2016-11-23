//
//  AugmentedViewController.mm
//  ARIS
//
//  Created by Michael Tolly on 11/23/16.
//
//

#import "AugmentedViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "ARISAlertHandler.h"
#import <Google/Analytics.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/TrackerManager.h>
#import <Vuforia/ObjectTracker.h>
#import <Vuforia/Trackable.h>
#import <Vuforia/DataSet.h>
#import <Vuforia/CameraDevice.h>

@interface AugmentedViewController() <AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate>
{
    Tab *tab;
    NSDate *lastError;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureSession *session;
    AVCaptureDevice *device;
    UIBarButtonItem *leftNavButton;
    id<AugmentedViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation AugmentedViewController

- (id) initWithTab:(Tab *)t delegate:(id<AugmentedViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tab = t;
        self.title = self.tabTitle;
        
        lastError = [NSDate date];
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorBlack];
    
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"In-Game Menu";
    leftNavButton = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    [self loadAVMetadataScanner];
    self.navigationItem.leftBarButtonItem = leftNavButton;
}

- (void) loadAVMetadataScanner
{
    
    // Create a new AVCaptureSession
    session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // Want the normal device
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) [session addInput:input];
    else { _ARIS_LOG_(@"error: %@", error); return; }
    
    // Display on screen
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.bounds = self.view.bounds;
    previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:previewLayer];
    
    [session stopRunning];
}

- (void) viewWillAppear:(BOOL)animated
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [session startRunning];
    previewLayer.opacity = 1.0; // show camera display after being hidden in viewDidDisappear
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [session stopRunning];
    previewLayer.opacity = 0.0; // hide camera display so you don't get a ghost image when scanner comes back
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"AUGMENTED"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return @"Augmented"; }
- (ARISMediaView *) tabIcon
{
    ARISMediaView *amv = [[ARISMediaView alloc] init];
    if(tab.icon_media_id)
        [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
    else
        [amv setImage:[UIImage imageNamed:@"qr_icon"]];
    return amv;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
