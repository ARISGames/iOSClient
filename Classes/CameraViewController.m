//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "CameraViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "TitleAndDecriptionFormViewController.h"

@implementation CameraViewController

@synthesize imagePickerController;
@synthesize cameraButton;
@synthesize libraryButton;
@synthesize mediaData;
@synthesize mediaFilename;
@synthesize profileButton;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if ((self = [super initWithNibName:nibName bundle:nibBundle])) {
        self.title = NSLocalizedString(@"CameraTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"camera.png"];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.imagePickerController = [[UIImagePickerController alloc] init];
	
	[libraryButton setTitle: NSLocalizedString(@"CameraLibraryButtonTitleKey",@"") forState: UIControlStateNormal];
	[libraryButton setTitle: NSLocalizedString(@"CameraLibraryButtonTitleKey",@"") forState: UIControlStateHighlighted];	
	
	[cameraButton setTitle: NSLocalizedString(@"CameraCameraButtonTitleKey",@"") forState: UIControlStateNormal];
	[cameraButton setTitle: NSLocalizedString(@"CameraCameraButtonTitleKey",@"") forState: UIControlStateHighlighted];	
    [profileButton setTitle:@"Take Profile Picture" forState:UIControlStateNormal];
    [profileButton setTitle:@"Take Profile Picture" forState:UIControlStateHighlighted];    
		
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		self.cameraButton.enabled = YES;
		self.cameraButton.alpha = 1.0;
        self.profileButton.enabled = YES;
        self.profileButton.alpha  = 1.0;
	}
	else {
		self.cameraButton.enabled = NO;
		self.cameraButton.alpha = 0.6;
        self.profileButton.enabled = NO;
        self.profileButton.alpha = 0.6;
	}
	
	self.imagePickerController.delegate = self;
	
	NSLog(@"Camera Loaded");
}


- (IBAction)cameraButtonTouchAction {
	NSLog(@"Camera Button Pressed");
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType];
	self.imagePickerController.allowsEditing = YES;
	self.imagePickerController.showsCameraControls = YES;
	[self presentModalViewController:self.imagePickerController animated:YES];
}


- (IBAction)libraryButtonTouchAction {
	NSLog(@"Library Button Pressed");
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentModalViewController:self.imagePickerController animated:YES];
}

- (IBAction)profileButtonTouchAction {
	NSLog(@"Profile Button Pressed");
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType];
	self.imagePickerController.allowsEditing = YES;
	self.imagePickerController.showsCameraControls = YES;
	[self presentModalViewController:self.imagePickerController animated:YES];
    [AppModel sharedAppModel].profilePic = YES;
}

#pragma mark UIImagePickerControllerDelegate Protocol Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info

{
	NSLog(@"CameraViewController: User Selected an Image or Video");
		
	[[picker parentViewController] dismissModalViewControllerAnimated:NO];

	//Get the data for the selected image or video
	NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	if ([mediaType isEqualToString:@"public.image"]){
		UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];             
		NSLog(@"CameraViewController: Found an Image");
		self.mediaData = UIImageJPEGRepresentation(image, 0.4);
		self.mediaFilename = @"image.jpg";
        UIImageWriteToSavedPhotosAlbum(image, 
                                       self, 
                                       @selector(image:didFinishSavingWithError:contextInfo:), 
                                       nil );
	}	
	else if ([mediaType isEqualToString:@"public.movie"]){
		NSLog(@"CameraViewController: Found a Movie");
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		self.mediaData = [NSData dataWithContentsOfURL:videoURL];
		self.mediaFilename = @"video.mp4";
	}	
	[self displayTitleandDescriptionForm];

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"Finished saving image with error: %@", error);
}

- (void)displayTitleandDescriptionForm {
    TitleAndDecriptionFormViewController *titleAndDescForm = [[TitleAndDecriptionFormViewController alloc] 
                                                              initWithNibName:@"TitleAndDecriptionFormViewController" bundle:nil];
	
	titleAndDescForm.delegate = self;
	[self.view addSubview:titleAndDescForm.view];
}

- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm{
	NSLog(@"CameraVC: Back from form");
	[titleAndDescForm.view removeFromSuperview];

	[[AppServices sharedAppServices] createItemAndGiveToPlayerFromFileData:self.mediaData 
										   fileName:self.mediaFilename 
											  title:titleAndDescForm.titleField.text 
										description:titleAndDescForm.descriptionField.text];
    
    [titleAndDescForm release];	
    NSString *tab;
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];        

    for(int i = 0;i < [appDelegate.tabBarController.customizableViewControllers count];i++)
    {
        tab = [[appDelegate.tabBarController.customizableViewControllers objectAtIndex:i] title];
        tab = [tab lowercaseString];
        if([tab isEqualToString:@"inventory"])
        {
            appDelegate.tabBarController.selectedIndex = i;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:NO];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[[picker parentViewController] dismissModalViewControllerAnimated:NO];
	
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
    [profileButton release];
    [cameraButton release];
    [libraryButton release];
    [super dealloc];
}


@end
