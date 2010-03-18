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



#pragma mark UIImagePickerControllerDelegate Protocol Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img 
				  editingInfo:(NSDictionary *)editInfo 
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];

			
	//turning the image in the UIView into a NSData JPEG object at 90% quality
	NSData *imageData = UIImageJPEGRepresentation(img, .8);
	
	[appModel createItemAndGiveToPlayerFromFileData:imageData andFileName:@"image.jpg"];
	
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
