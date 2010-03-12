//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
        self.title = @"Scanner";
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
	
	NSLog(@"QRScannerViewController: Loaded");
}

- (IBAction)scanButtonTouchAction: (id) sender{
	NSLog(@"QRScannerViewController: Scan Button Pressed");
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:self.imagePickerController animated:YES];
	 
}

- (IBAction)codeEnteredAction: (id) sender{
	NSLog(@"QRScannerViewController: Code Entered");
	[self loadResult:manualCode.text];
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

-(void) loadResult:(NSString *)encodedText {
	//Fetch the coresponding object from the server
	NSObject<QRCodeProtocol> *qrCodeObject = [appModel fetchQRCode:encodedText];
	
	if (qrCodeObject == nil) {
		//Display an alert
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Decoding Error" message:@"This code is not a part of your current ARIS game"
			 delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
					  
	}
	else {	
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
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Decoding Error" message:@"Try scanning the code again: Step back 2 feet and hold the camera as still as possible"
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
	[appDelegate showWaitingIndicator:@"Decoding..."];
	
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
