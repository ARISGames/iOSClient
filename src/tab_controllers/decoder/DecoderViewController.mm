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

@interface DecoderViewController()
{
    id<DecoderViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation DecoderViewController

@synthesize manualCode,resultText,cancelButton;

- (id) initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithNibName:@"DecoderViewController" bundle:nil])
    {
        self.tabID = @"QR";

        delegate = d;
        
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"qrScannerTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"qrScannerTabBarUnselected"]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadingResult:) name:@"QRCodeObjectReady" object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
		
	manualCode.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
	
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelKey",@"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTouch)];      
}

-(void)cancelButtonTouch
{
    [self.manualCode resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
	
	[self loadResult:manualCode.text];
    self.navigationItem.rightBarButtonItem = nil;	
	return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{    
    self.navigationItem.rightBarButtonItem = self.cancelButton;	
    return YES;
}

- (IBAction) scanButtonTapped
{
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    widController.readers = [[NSMutableSet alloc ] initWithObjects:[[QRCodeReader alloc] init], nil];
    [self presentModalViewController:widController animated:NO];
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    [self dismissModalViewControllerAnimated:NO];
    [self loadResult:result];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [self dismissModalViewControllerAnimated:NO];
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
