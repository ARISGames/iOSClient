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
   	UIButton *scanButton; 
    
    BOOL textEnabled;
    BOOL scanEnabled;
    NSString *prompt;
    ZXingWidgetController *widController;
    id<DecoderViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) ZXingWidgetController *widController;

@end

@implementation DecoderViewController

@synthesize codeTextField;
@synthesize scanButton;
@synthesize widController;

- (id) initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d inMode:(int)m
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"QR";
        self.tabIconName = @"qr_small";
        
        textEnabled = (m == 0 || m == 1);
        scanEnabled = (m == 0 || m == 2);
        prompt = @""; 
        
        delegate = d;
        
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadingResult:) name:@"QRCodeObjectReady" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorBlack];  
    
    if(textEnabled)
    {
        self.view.backgroundColor = [UIColor ARISColorWhite]; 
        self.codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20,20+64,self.view.frame.size.width-40,30)];
        self.codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.codeTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.codeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.codeTextField.textAlignment = NSTextAlignmentCenter;
        self.codeTextField.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
        self.codeTextField.delegate = self;
        [self.view addSubview:self.codeTextField];
    }
    
    if(scanEnabled)
    {
        self.scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.scanButton.frame = CGRectMake(20,70+64,self.view.frame.size.width-40,30);
        self.scanButton.backgroundColor = [UIColor ARISColorDarkGray];
        [self.scanButton setTitle:@"Scan" forState:UIControlStateNormal];
        [self.scanButton addTarget:self action:@selector(scanButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        if(textEnabled) [self.view addSubview:self.scanButton]; //else, don't bother adding it to view as it should always be open
    }
}

- (void) viewWillAppearFirstTime:(BOOL)animated
{
    [super viewWillAppearFirstTime:animated];
    
    //overwrite the nav button written by superview so we can listen for touchDOWN events as well (to dismiss camera)
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threeLines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside]; 
    if(textEnabled)
        [threeLineNavButton addTarget:self action:@selector(clearScreenActions) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];  
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self clearScreenActions]; 
    
    if(!textEnabled || ![prompt isEqualToString:@""]) [self launchScanner];
    if(!scanEnabled) [self.codeTextField becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearScreenActions];
}

- (void) showNav
{
    if(textEnabled) [self clearScreenActions];
    [super showNav];
}

- (void) clearScreenActions
{
    if(self.codeTextField) [self.codeTextField resignFirstResponder];
    if(self.widController) [self hideWidController];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
	
	[self loadResult:self.codeTextField.text];
	return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{    
    return YES;
}

- (void) setPrompt:(NSString *)p
{
    prompt = p;
}

- (void) launchScanner
{
    [self clearScreenActions];
    self.widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO showLicense:NO withPrompt:prompt];
    self.widController.readers = [[NSMutableSet  alloc] initWithObjects:[[QRCodeReader alloc] init], nil];
    prompt = @"";
    
    [self.view addSubview:self.widController.view];
}

- (void) scanButtonTouched
{
    [self launchScanner];
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
    [self.widController.view removeFromSuperview];
    self.widController = nil;
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
        if(!textEnabled) [self performSelector:@selector(scanButtonTouched) withObject:nil afterDelay:1]; 
	}
	else if([qrCodeObject isKindOfClass:[NSString class]])
    {
        [appDelegate playAudioAlert:@"error" shouldVibrate:NO];
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"") message:(NSString *)qrCodeObject];
        if(!textEnabled) [self performSelector:@selector(scanButtonTouched) withObject:nil afterDelay:1];  
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
