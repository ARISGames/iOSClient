//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "QRScannerViewController.h"
#import "Decoder.h"
#import "TwoDDecoderResult.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"


@implementation QRScannerViewController 

@synthesize imagePickerController;
@synthesize scanButton;
@synthesize manualCode;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QRScannerTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"qrscanner.png"];
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	self.imagePickerController = [[UIImagePickerController alloc] init];
	self.imagePickerController.allowsImageEditing = YES;
	self.imagePickerController.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		self.scanButton.enabled = YES;
		self.scanButton.alpha = 1.0;
	}
	else {
		self.scanButton.enabled = NO;
		self.scanButton.alpha = 0.6;
	}
	
	
	NSLog(@"QRScannerViewController: Loaded");
}

- (IBAction)scanButtonTouchAction: (id) sender{
	NSLog(@"QRScannerViewController: Scan Button Pressed");
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:self.imagePickerController animated:YES];
	 
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	[[picker parentViewController] dismissModalViewControllerAnimated:NO];
	CGRect cropRect;
	//if ([editInfo objectForKey:UIImagePickerControllerCropRect]) {  //do we have a user specified cropRect?
	//	cropRect = [[editInfo objectForKey:UIImagePickerControllerCropRect] CGRectValue];
	//} else { //No user-specified croprect, so set cropRect to use entire image
		cropRect = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
	//}
	
	//Now to decode
	Decoder *imageDecoder = [[Decoder alloc] init]; //create a decoder
	[imageDecoder setDelegate:self];  //we get told about the scan, 
	[imageDecoder decodeImage:img cropRect:cropRect]; //start the decode. When done, our delegate method will be called.
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[picker parentViewController] dismissModalViewControllerAnimated:NO];
}

#pragma mark QRCScan delegate methods

- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)twoDResult {
	//Stop Waiting Indicator
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate removeWaitingIndicator];
	
	//get the result
	NSString *encodedText = twoDResult.text;

	//we are done with the scanner, so release it
	[decoder release];
	NSLog(@"QRScannerViewController: Decode Complete. QR Code ID = %@", encodedText);
	
	[self loadResult:encodedText];
}	

-(void) loadResult:(NSString *)code {
	//Fetch the coresponding object from the server
	NSObject<QRCodeProtocol> *qrCodeObject = [appModel fetchQRCode:code];
	
	if (qrCodeObject == nil) {
		ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
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
		ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
		
		//Display the content
		[qrCodeObject display];
	}
}

- (void)decoder:(Decoder *)decoder decodingImage:(UIImage *)image usingSubset:(UIImage *)subset progress:(NSString *)message {
	NSLog(@"Decoding image");
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
	NSLog(@"Failed to decode image");
	[decoder release];
	
	//Stop Waiting Indicator
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate removeWaitingIndicator];
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
	[appDelegate showWaitingIndicator:NSLocalizedString(@"QRScannerDecodingKey",@"") displayProgressBar:NO];
	
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
    [super dealloc];
}


@end
