//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DecoderViewController.h"
#import "StateControllerProtocol.h"
#import "Decoder.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import "QRCodeReader.h"
#import "ARISAlertHandler.h"
#import "UIColor+ARISColors.h"

@interface DecoderViewController() <ZXingDelegate, UITextFieldDelegate>
{
	UITextField *codeTextField;
    
    ZXingWidgetController *widController;
    id<DecoderViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UITextField *codeTextField;

@end

@implementation DecoderViewController

@synthesize codeTextField;

- (id) initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"QR";

        delegate = d;
        
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"qrScannerTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"qrScannerTabBarSelected"]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadingResult:) name:@"QRCodeObjectReady" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorWhite];
    
    codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20,20,self.view.frame.size.width-40,30)];
    codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    codeTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    codeTextField.textAlignment = NSTextAlignmentCenter;
	codeTextField.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
    codeTextField.delegate = self;
    [self.view addSubview:codeTextField];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scanBtn.frame = CGRectMake(20,70,self.view.frame.size.width-40,30);
    scanBtn.backgroundColor = [UIColor ARISColorDarkGray];
    [scanBtn setTitle:@"Scan" forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanBtn];
	
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threeLines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
}

- (void) showNav
{
    [self clearScreenActions];
    [super showNav];
}

     
 - (void) clearScreenActions
 {
     [self.codeTextField resignFirstResponder];
     if(widController) [self hideWidController];
 }

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
	
	[self loadResult:codeTextField.text];
	return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{    
    return YES;
}

- (void) launchScannerWithPrompt:(NSString *)p
{
    widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO showLicense:NO withPrompt:p];
    widController.readers = [[NSMutableSet alloc ] initWithObjects:[[QRCodeReader alloc] init], nil];
    
    [self.view addSubview:widController.view];
}

- (void) scanButtonTouched
{
    [self launchScannerWithPrompt:@""];
}

- (void) zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    [self hideWidController];
    [self loadResult:result];
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

- (void) loadResult:(NSString *)code
{
    if([code isEqualToString:@"log-out"])
    {
        NSLog(@"NSNotification: LogoutRequested");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        return;
    }
    
    [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"")];
	[[AppServices sharedAppServices] fetchQRCode:code];
}

- (void) finishLoadingResult:(NSNotification*) notification
{	
	NSObject *qrCodeObject = notification.object;
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
    
	if(!qrCodeObject)
    {
		[appDelegate playAudioAlert:@"error" shouldVibrate:NO];
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"") message:NSLocalizedString(@"QRScannerErrorMessageKey", @"")];
	}
	else if([qrCodeObject isKindOfClass:[NSString class]])
    {
        [appDelegate playAudioAlert:@"error" shouldVibrate:NO];
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"") message:(NSString *)qrCodeObject];
    }
    else
    {
		[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
		[delegate displayGameObject:((id<GameObjectProtocol>)((Location *)qrCodeObject).gameObject) fromSource:(Location *)qrCodeObject];
	}
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
