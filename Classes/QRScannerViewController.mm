//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "QRScannerViewController.h"
#import "Decoder.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import <QRCodeReader.h>
#import "ZBarReaderViewController.h"


@implementation QRScannerViewController 

@synthesize imageMatchingImagePickerController;
@synthesize qrScanButton,imageScanButton,barcodeButton;
@synthesize manualCode,resultText;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	//[self.qrScanButton setTitle:NSLocalizedString(@"ScanUsingCameraKey",@"") forState:UIControlStateNormal];
	manualCode.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
	    
	self.imageMatchingImagePickerController = [[UIImagePickerController alloc] init];
	self.imageMatchingImagePickerController.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		self.qrScanButton.enabled = YES;
		self.qrScanButton.alpha = 1.0;
        self.imageScanButton.enabled = YES;
		self.imageScanButton.alpha = 1.0;
	}
	else {
		self.qrScanButton.hidden = YES;
        self.imageScanButton.hidden = YES;
        [self.manualCode becomeFirstResponder]; 
	}
	
	
	NSLog(@"QRScannerViewController: Loaded");
}
- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    [reader release];
}

- (IBAction)qrScanButtonTouchAction: (id) sender{
	NSLog(@"QRScannerViewController: QR Scan Button Pressed");
	
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    [qrcodeReader release];
    widController.readers = readers;
    [readers release];
    /*
    NSBundle *mainBundle = [NSBundle mainBundle];
    widController.soundToPlay =
    [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-beep" ofType:@"aiff"] isDirectory:NO];
     */
    [self presentModalViewController:widController animated:YES];
    [widController release];
	 
}

- (IBAction)imageScanButtonTouchAction: (id) sender{
    NSLog(@"QRScannerViewController: Image Scan Button Pressed");
	
	self.imageMatchingImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:self.imageMatchingImagePickerController animated:YES];
    
}


#pragma mark Delegate for text entry

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
	NSLog(@"QRScannerViewController: Code Entered");
	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
	
	[self loadResult:manualCode.text];
	
	return YES;
	
}



#pragma mark UIImagePickerControllerDelegate Protocol Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info{

	//[[picker parentViewController] dismissModalViewControllerAnimated:NO];
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    [appDelegate dismissNearbyObjectView:self];
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];                 
    
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    resultText = symbol.data;
   
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
   // [picker dismissModalViewControllerAnimated: YES];
    
    
    if (picker == self.imageMatchingImagePickerController) {
        NSLog(@"QRScannerVC: image matching imagePickerController didFinishPickingImage" );
        
        NSData *imageData = UIImageJPEGRepresentation(image, .4);
        [[AppServices sharedAppServices] uploadImageForMatching:imageData];
    }	
    else{
        NSLog(@"QRSCannerVC: barcode data = %@",resultText);
        [self loadResult:resultText];

    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    [appDelegate dismissNearbyObjectView:self];
}


#pragma mark -
#pragma mark ZXingDelegateMethods
- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)resultString {
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    [appDelegate dismissNearbyObjectView:self];
    NSLog(@"QRScannerViewController: Scan result: %@",resultString);
    [self loadResult:resultString];
    
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;
    [appDelegate dismissNearbyObjectView:self];}


#pragma mark QRCScan delegate methods
/*
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)twoDResult {
	//Stop Waiting Indicator
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
	
	//get the result
	NSString *encodedText = twoDResult.text;

	//we are done with the scanner, so release it
	[decoder release];
	NSLog(@"QRScannerViewController: Decode Complete. QR Code ID = %@", encodedText);
	
	[self loadResult:encodedText];
}
 
 - (void)decoder:(Decoder *)decoder decodingImage:(UIImage *)image usingSubset:(UIImage *)subset progress:(NSString *)message {
 NSLog(@"Decoding image");
 }
 
 - (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
 NSLog(@"Failed to decode image");
 [decoder release];
 
 //Stop Waiting Indicator
 ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
 [appDelegate removeNewWaitingIndicator];
 [appDelegate playAudioAlert:@"error" shouldVibrate:YES];
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerDecodingErrorTitleKey", @"")
 message:NSLocalizedString(@"QRScannerDecodingErrorMessageKey", @"")
 delegate:self 
 cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
 otherButtonTitles:nil];
 [alert show];	
 [alert release];
 }
 
 - (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode {
 NSLog(@"Not implemented.");
 assert(false);
 }
 
 - (void)decoder:(Decoder *)decoder willDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset {
 NSLog(@"QR: Will decode image");
 
 //Start Waiting Indicator
 ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
 [appDelegate showNewWaitingIndicator:NSLocalizedString(@"QRScannerDecodingKey",@"") displayProgressBar:NO];
 
 }
 

*/



-(void) loadResult:(NSString *)code {
	//Fetch the coresponding object from the server
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate showNewWaitingIndicator:NSLocalizedString(@"LoadingKey",@"") displayProgressBar:NO];
	[[AppServices sharedAppServices] fetchQRCode:code];
}

-(void) finishLoadingResult:(NSNotification*) notification{
	
	NSObject<QRCodeProtocol> *qrCodeObject = notification.object;
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];

	if (qrCodeObject == nil) {
		[appDelegate playAudioAlert:@"error" shouldVibrate:NO];
		
		//Display an alert
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"")
														message:NSLocalizedString(@"QRScannerErrorMessageKey", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
											  otherButtonTitles:nil];
		[alert show];	
		[alert release];
		
	}
	else {	
        if ([qrCodeObject isKindOfClass:[NSString class]]) {
            [appDelegate playAudioAlert:@"error" shouldVibrate:NO];
            
            //Display an alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"")
                                                            message:(NSString *)qrCodeObject
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
                                                  otherButtonTitles:nil];
            [alert show];	
            [alert release];
            
        }
		[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];		
		//Display the content
		[qrCodeObject display];
	}
}


#pragma mark UINavigationControllerDelegate Protocol Methods
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	//nada
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	//nada
}


#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


@end
