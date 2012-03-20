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
#import "GPSViewController.h"
#import "NoteCommentViewController.h"
#import "NoteEditorViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"

@implementation CameraViewController

//@synthesize imagePickerController;
@synthesize cameraButton;
@synthesize libraryButton;
@synthesize mediaData;
@synthesize mediaFilename;
@synthesize profileButton,parentDelegate,backView,showVid, noteId,editView;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if ((self = [super initWithNibName:nibName bundle:nibBundle])) {
        self.title = NSLocalizedString(@"CameraTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"camera.png"];
        bringUpCamera = YES;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.imagePickerController = [[UIImagePickerController alloc] init];
	
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
	
	//self.imagePickerController.delegate = self;
	
	NSLog(@"Camera Loaded");
}

-(void)viewWillAppear:(BOOL)animated{
    if(bringUpCamera){
        bringUpCamera = NO;

   if(showVid) [self cameraButtonTouchAction];
    else [self libraryButtonTouchAction];
    }
}

- (IBAction)cameraButtonTouchAction {
	NSLog(@"Camera Button Pressed");
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
		picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
	[self presentModalViewController:picker animated:NO];
    [picker release];
}

        
/*- (BOOL) isVideoCameraAvailable{
       // UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType];
        
        if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ]){
            
            return NO;
        }
        
        return YES;
    }*/

- (IBAction)libraryButtonTouchAction {
	NSLog(@"Library Button Pressed");
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
	[self presentModalViewController:picker animated:NO];
    [picker release];
}

- (IBAction)profileButtonTouchAction {
	NSLog(@"Profile Button Pressed");
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;

	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
	picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
	[self presentModalViewController:picker animated:NO];
    [picker release];
    [AppModel sharedAppModel].profilePic = YES;
}

#pragma mark UIImagePickerControllerDelegate Protocol Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary  *)info

{
	NSLog(@"CameraViewController: User Selected an Image or Video");
		
	//[[picker parentViewController] dismissModalViewControllerAnimated:NO];
    [picker dismissModalViewControllerAnimated:NO];

	//Get the data for the selected image or video
	NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	
	if ([mediaType isEqualToString:@"public.image"]){
		UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];             
		NSLog(@"CameraViewController: Found an Image");
        
		self.mediaData = UIImageJPEGRepresentation(image, 0.4);
		self.mediaFilename = [NSString stringWithFormat:@"%@image.jpg",[NSDate date]];
        if(showVid){
            //if you are actually taking a photo or video then save it
            void *context;
        UIImageWriteToSavedPhotosAlbum(image, 
                                       self, 
                                       @selector(image:didFinishSavingWithError:contextInfo:), 
                                       context );
        }

        NSString *newFilePath =[NSTemporaryDirectory() stringByAppendingString: [NSString stringWithFormat:@"%@image.jpg",[NSDate date]]];
        
            NSURL *imageURL = [[NSURL alloc] initFileURLWithPath: newFilePath];

        
        if (self.mediaData != nil) {
            NSLog(@"HERE [%@]", newFilePath);
            [mediaData writeToURL:imageURL atomically:YES];
        }
        
        if([self.parentDelegate isKindOfClass:[NoteCommentViewController class]]) {
                       [self.parentDelegate addedPhoto];

        }
        
        if([self.editView isKindOfClass:[NoteEditorViewController class]]) {
            [self.editView setNoteValid:YES];
            [self.editView setNoteChanged:YES];
                  }
        
        [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:kNoteContentTypePhoto withFileURL:imageURL];
	}	
	else if ([mediaType isEqualToString:@"public.movie"]){
		NSLog(@"CameraViewController: Found a Movie");
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		self.mediaData = [NSData dataWithContentsOfURL:videoURL];
		self.mediaFilename = @"video.mp4";
        if([self.parentDelegate isKindOfClass:[NoteCommentViewController class]]){ 
                       [self.parentDelegate addedVideo];

        }
        if([self.editView isKindOfClass:[NoteEditorViewController class]]) {
            [self.editView setNoteValid:YES];
            [self.editView setNoteChanged:YES];
                 }
        
  [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:kNoteContentTypeVideo withFileURL:videoURL];
    
    }	
    

    [self.navigationController popViewControllerAnimated:NO];
   


}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"Finished saving image with error: %@", error);
}

-(void) uploadMedia {
    }

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:NO];
    if([backView isKindOfClass:[NotebookViewController class]]){
        [[AppServices sharedAppServices]deleteNoteWithNoteId:self.noteId];
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.noteId]];   
    }
    [self.navigationController popToViewController:self.backView animated:NO];
	
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
    NSLog(@"CAMERA DID RECEIVE MEMORY WARNING!");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	//[imagePickerController release];
    [super dealloc];
    if(profileButton)
    [profileButton release];
    if(cameraButton)
    [cameraButton release];
    if(libraryButton)
    [libraryButton release];
    if(mediaData)
    [mediaData release];
    if(mediaFilename)
    [mediaFilename release];
    //if(backView)
    //[backView release];
    //if(editView)
    //[editView release];
    //if(parentDelegate)
    //[parentDelegate release];
    
}


@end
