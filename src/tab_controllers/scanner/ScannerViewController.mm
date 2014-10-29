//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ScannerViewController.h"
#import <ZXingWidgetController.h>
#import "StateControllerProtocol.h"
#import "Decoder.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "QRCodeReader.h"
#import "ARISAlertHandler.h"

@interface ScannerViewController() <ZXingDelegate, UITextFieldDelegate>
{
    NSString *prompt;
    
    NSDate *lastError;
    ZXingWidgetController *widController;
    id<ScannerViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation ScannerViewController

- (id) initWithDelegate:(id<ScannerViewControllerDelegate>)d
{
    if(self = [super init])
    {
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
    
    [self launchScanner];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearScreenActions];
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

- (void) clearScreenActions
{
    [self hideWidController];
}

-  (void) setPrompt:(NSString *)p
{
    prompt = p;
    if(self.view) [self launchScanner]; //hack to ensure view is loaded
}

- (void) launchScanner
{
    [self clearScreenActions];
    widController = [[ZXingWidgetController alloc] initWithDelegate:self oneDMode:NO showLicense:NO withPrompt:prompt];
    widController.readers = [[NSMutableSet  alloc] initWithObjects:[[QRCodeReader alloc] init], nil];
    prompt = @"";
    [self performSelector:@selector(addWidSubview) withObject:Nil afterDelay:0.1];
}

- (void) addWidSubview
{
    [self.view addSubview:widController.view];
}

- (void) zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [self hideWidController];
}

- (void) hideWidController
{
    [widController.view removeFromSuperview];
    widController = nil;
}

- (void) zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    [self hideWidController];
	
    Trigger *t;
    if([result isEqualToString:@"log-out"]) [_MODEL_ logOut];
    else 
    {
        t = [_MODEL_TRIGGERS_ triggerForQRCode:result];
    
    	if(!t) 
        {
            if([lastError timeIntervalSinceNow] < -3.0f)
            { 
                lastError = [NSDate date];
                [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"") message:NSLocalizedString(@"QRScannerErrorMessageKey", @"")];
                [self performSelector:@selector(launchScanner) withObject:nil afterDelay:1]; 
            }
            //else ignore false reading
        }
        else [delegate displayTrigger:t];
    }
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"SCANNER"; }
- (NSString *) tabTitle { return @"Scanner"; }
- (UIImage *) tabIcon { return [UIImage imageNamed:@"qr_icon"]; }

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self); 
}

@end
