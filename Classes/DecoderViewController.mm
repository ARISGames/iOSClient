//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DecoderViewController.h"
#import "Decoder.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import <QRCodeReader.h>
#import "ARISZBarReaderWrapperViewController.h"


@implementation DecoderViewController

@synthesize imageMatchingImagePickerController;
@synthesize qrScanButton,imageScanButton,barcodeButton;
@synthesize manualCode,resultText,cancelButton;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"qrscanner.png"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(finishLoadingResult:)
													 name:@"QRCodeObjectReady"
												   object:nil];
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

- (IBAction)scanButtonTapped
{
    //ARISZBarReaderWrapperViewController *reader = [[ARISZBarReaderWrapperViewController alloc] init];
    ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    reader.supportedOrientationsMask = 0;
    
    [scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
    
    [self presentViewController:reader animated:NO completion:nil];
}

- (IBAction)imageScanButtonTouchAction:(id)sender
{
    NSLog(@"DecoderViewController: Image Scan Button Pressed");
	
	self.imageMatchingImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentViewController:self.imageMatchingImagePickerController animated:YES completion:nil];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];                 
    
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) break;
    
    resultText = symbol.data;
    
    if (picker == self.imageMatchingImagePickerController)
    {
        NSLog(@"DecoderVC: image matching imagePickerController didFinishPickingImage" );
        
        NSData *imageData = UIImageJPEGRepresentation(image, .4);
        NSString *mediaFilename = @"imageToMatch.jpg";
        NSString *newFilePath = [NSTemporaryDirectory() stringByAppendingString:mediaFilename];
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:newFilePath];
        
        NSLog(@"Tempory File will be: %@", newFilePath);
        [imageData writeToURL:imageURL atomically:YES];
        [[AppServices sharedAppServices] uploadImageForMatching:imageURL];
    }	
    else
    {
        NSLog(@"DecoderVC: barcode data = %@",resultText);
        [self loadResult:resultText];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:NO completion:nil];
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
    
	[[RootViewController sharedRootViewController] showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"") displayProgressBar:NO];
	[[AppServices sharedAppServices] fetchQRCode:code];
}

-(void) finishLoadingResult:(NSNotification*) notification
{	
	NSObject<QRCodeProtocol> *qrCodeObject = notification.object;
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[RootViewController sharedRootViewController] removeWaitingIndicator];
    
	if (qrCodeObject == nil) {
		[appDelegate playAudioAlert:@"error" shouldVibrate:NO];
		
		//Display an alert
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
        
        //Display an alert
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
		//Display the content
		[qrCodeObject display];
	}
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


@end
