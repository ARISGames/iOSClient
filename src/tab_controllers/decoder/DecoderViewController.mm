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

@synthesize imageMatchingImagePickerController;
@synthesize qrScanButton,imageScanButton,barcodeButton;
@synthesize manualCode,resultText,cancelButton;

- (id)initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithNibName:@"DecoderViewController" bundle:nil])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"qrscanner.png"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLoadingResult:) name:@"QRCodeObjectReady" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	//[self.qrScanButton setTitle:NSLocalizedString(@"ScanUsingCameraKey",@"") forState:UIControlStateNormal];
	manualCode.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
	    
	imageMatchingImagePickerController = [[UIImagePickerController alloc] init];
	self.imageMatchingImagePickerController.delegate = self;
	
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelKey",@"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTouch)];      
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		self.qrScanButton.enabled = YES;
		self.qrScanButton.alpha = 1.0;
        self.imageScanButton.enabled = YES;
		self.imageScanButton.alpha = 1.0;
	}
	else {
		self.qrScanButton.hidden = YES;
		self.barcodeButton.hidden = YES;
        self.imageScanButton.hidden = YES;
        [self.manualCode becomeFirstResponder]; 

	}
	NSLog(@"DecoderViewController: Loaded");
}

-(void)cancelButtonTouch
{
    [self.manualCode resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;	
}

- (IBAction)imageScanButtonTouchAction:(id)sender
{
    NSLog(@"DecoderViewController: Image Scan Button Pressed");
	
	self.imageMatchingImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentViewController:self.imageMatchingImagePickerController animated:NO completion:nil];
}

#pragma mark Delegate for text entry

-(BOOL) textFieldShouldReturn:(UITextField*)textField
{
	NSLog(@"DecoderViewController: Code Entered");
	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
	
	[self loadResult:manualCode.text];
    self.navigationItem.rightBarButtonItem = nil;	
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{    
    self.navigationItem.rightBarButtonItem = self.cancelButton;	
    return YES;
}

#pragma mark UIImagePickerControllerDelegate Protocol Methods

- (IBAction)scanButtonTapped
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

#pragma mark -

#pragma mark QRCScan delegate methods

-(void) loadResult:(NSString *)code
{
	//Fetch the coresponding object from the server
    if([code isEqualToString:@"log-out"])
    {
        NSLog(@"NSNotification: LogoutRequested");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self]];
        return;
    }
    
    [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"")];
	[[AppServices sharedAppServices] fetchQRCode:code];
}

-(void) finishLoadingResult:(NSNotification*) notification
{	
	NSObject *qrCodeObject = notification.object;
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
    
	if (qrCodeObject == nil) {
		[appDelegate playAudioAlert:@"error" shouldVibrate:NO];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"")
														message:NSLocalizedString(@"QRScannerErrorMessageKey", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
											  otherButtonTitles:nil];
		[alert show];	
		
	}
	else if ([qrCodeObject isKindOfClass:[NSString class]])
    {
        [appDelegate playAudioAlert:@"error" shouldVibrate:NO];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"")
                                                        message:(NSString *)qrCodeObject
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
		[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
		[delegate displayGameObject:((id<GameObjectProtocol>)qrCodeObject) fromSource:self];
	}
}

#pragma mark Rotation

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

-(BOOL) shouldAutorotate
{
    return YES;
}

-(NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
