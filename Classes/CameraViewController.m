//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"

static NSString *const kBoundaryMagicString  = @"---------------------------14737809831466499882746641449";

@interface CameraViewController()
- (NSData *) encode:(NSString *)data forPostWithName:(NSString *)name;
@end


@implementation CameraViewController

@synthesize imagePickerController;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        self.title = @"Camera";
        self.tabBarItem.image = [UIImage imageNamed:@"camera.png"];
		
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];

    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.imagePickerController = [[UIImagePickerController alloc] init];
	[imagePickerController release];
	self.imagePickerController.allowsImageEditing = YES;
	self.imagePickerController.delegate = self;
	
	NSLog(@"Camera Loaded");
}


- (IBAction)cameraButtonTouchAction {
	NSLog(@"Camera Button Pressed");
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:self.imagePickerController animated:YES];
}

- (NSData *) encode:(NSString *)data forPostWithName:(NSString *)name {
	NSData *result = [[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n--%@\r\n",
						 name, data, kBoundaryMagicString] dataUsingEncoding:NSUTF8StringEncoding] autorelease];
	return result;	
}

#pragma mark UIImagePickerControllerDelegate Protocol Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img 
				  editingInfo:(NSDictionary *)editInfo 
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Test" 
													message:[NSString stringWithFormat:@"Sending to %@", appModel.baseAppURL]
												   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[a show];
	[a release];
	
	NSLog(@"Preparing to send file from camera to Server");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//turning the image in the UIView into a NSData JPEG object at 90% quality
	NSData *imageData = UIImageJPEGRepresentation(img, .9);
	
	// setting up the request object now
	NSURL *url = [[[NSURL alloc] initWithString:appModel.baseAppURL] autorelease];
	NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[request setHTTPMethod: @"POST"];
	
	//Add headers
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//body
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// GameID
	[body appendData:[self encode:[NSString stringWithFormat:@"%d", appModel.gameId] forPostWithName:@"gameID"]];
	
	//image
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"file\"; filename=\"ipodfile.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	// post it
	NSURLResponse *response;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"Camera file posted. Result from Server: %@", returnString);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [pool drain];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Taken" 
													message:@"It is available in your inventory" 
												   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark UINavigationControllerDelegate Protocol Methods
- (void)navigationController:(UINavigationController *)navigationController 
	   didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//nada
}

- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//nada
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[imagePickerController release];
    [super dealloc];
}


@end
