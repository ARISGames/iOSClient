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
#import "UIImage+Scale.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import <ImageIO/ImageIO.h>

@implementation CameraViewController

//@synthesize imagePickerController;
@synthesize cameraButton;
@synthesize libraryButton;
@synthesize mediaData;
@synthesize mediaFilename;
@synthesize profileButton,parentDelegate,backView,showVid, noteId,editView,picker;

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
    picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
	[self presentModalViewController:picker animated:NO];
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
    picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
	[self presentModalViewController:picker animated:NO];
}

- (IBAction)profileButtonTouchAction {
	NSLog(@"Profile Button Pressed");
    picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;

	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
	picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
	[self presentModalViewController:picker animated:NO];
    [AppModel sharedAppModel].profilePic = YES;
}

#pragma mark UIImagePickerControllerDelegate Protocol Methods
- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
	NSLog(@"CameraViewController: User Selected an Image or Video");
    [aPicker dismissModalViewControllerAnimated:NO];

	NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //Manipulate image to desired specs (quality, orientation, size, etc...)
        image = [image fixOrientation];
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size interpolationQuality:kCGInterpolationHigh];
        if(image.size.height > image.size.width)
        {
            if(image.size.height > 856)
                image = [image scaleToSize:CGSizeMake(image.size.width*(856/image.size.height), 856)];
            if(image.size.width > 640)
                image = [image scaleToSize:CGSizeMake(640, image.size.height*(640/image.size.width))];
        }
        else
        {
            if(image.size.width > 856)
                image = [image scaleToSize:CGSizeMake(856, image.size.height*(856/image.size.width))];
            if(image.size.height > 640)
                image = [image scaleToSize:CGSizeMake(image.size.width*(640/image.size.height), 640)];
        }
        
        //Image Data
        self.mediaData = UIImageJPEGRepresentation(image, 0.4);
        self.mediaFilename = [NSString stringWithFormat:@"%@image.jpg",[NSDate date]];
        NSString *newFilePath =[NSTemporaryDirectory() stringByAppendingString: [NSString stringWithFormat:@"%@image.jpg",[NSDate date]]];
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath: newFilePath];
        if (self.mediaData != nil) [mediaData writeToURL:imageURL atomically:YES];
        
        //Image Meta Data
        NSMutableDictionary *newMetadata = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        CLLocation * location = [AppModel sharedAppModel].playerLocation;
        [newMetadata setLocation:location];
        NSString *gameName = [AppModel sharedAppModel].currentGame.name;
        NSString *descript = [[NSString alloc] initWithFormat: @"%@ %@: %@. %@: %@", NSLocalizedString(@"CameraImageTakenKey", @""), NSLocalizedString(@"CameraGameKey", @""), gameName, NSLocalizedString(@"CameraPlayerKey", @""), [[AppModel sharedAppModel] userName]];
        [newMetadata setDescription: descript];
        
        //Handle Delegate
        if([self.parentDelegate isKindOfClass:[NoteCommentViewController class]])
            [self.parentDelegate addedPhoto];
        if([self.editView isKindOfClass:[NoteEditorViewController class]])
        {
            [self.editView setNoteValid:YES];
            [self.editView setNoteChanged:YES];
        }
            
        // If image not selected from camera roll, save image with metadata to camera roll
        if ([info objectForKey:UIImagePickerControllerReferenceURL] == NULL)
        {
            ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
            [al writeImageDataToSavedPhotosAlbum:self.mediaData metadata:newMetadata completionBlock:^(NSURL *assetURL, NSError *error)
            {
                // once image is saved, get asset from assetURL
                [al assetForURL:assetURL resultBlock:^(ALAsset *asset)
                {
                    if (!asset) return;
                    
                    // save image to temporary directory to be able to upload it
                    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                    UIImage * image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]];
                    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
                    imageData = [self dataWithEXIFUsingData:imageData];
                    
                    NSString *newFilePath =[NSTemporaryDirectory() stringByAppendingString: [NSString stringWithFormat:@"%@image.jpg",[NSDate date]]];
                    NSURL *imageURL = [[NSURL alloc] initFileURLWithPath: newFilePath];
                    
                    [imageData writeToURL:imageURL atomically:YES];
                    
                    //Do the upload
                    [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:kNoteContentTypePhoto withFileURL:imageURL];
                    if([self.editView isKindOfClass:[NoteEditorViewController class]])
                        [self.editView refreshViewFromModel];
                }
                failureBlock:^(NSError *error) {}
                ];
            }];
        } 
        else {
            //Do the upload
            [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:kNoteContentTypePhoto withFileURL:imageURL];
            if([self.editView isKindOfClass:[NoteEditorViewController class]])
                [self.editView refreshViewFromModel];
        }
                                                                                                                                                                             
        
        
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

-(void) uploadMedia
{
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker {
    [aPicker dismissModalViewControllerAnimated:NO];
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
    [self.picker dismissModalViewControllerAnimated:NO];
    [self.navigationController popViewControllerAnimated:NO];

    /*
     Try to let go of the camera to save a crash
    if (self.modalViewController.retainCount)
    {
        [self dismissModalViewControllerAnimated:NO];
        [self.modalViewController release];
    }
    */

}

- (NSMutableData*)dataWithEXIFUsingData:(NSData*)originalJPEGData {	
    NSMutableData* newJPEGData = [[NSMutableData alloc] init];
    NSMutableDictionary* exifDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* locDict = [[NSMutableDictionary alloc] init];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
	
    CGImageSourceRef img = CGImageSourceCreateWithData((__bridge CFDataRef)originalJPEGData, NULL);
    CLLocationDegrees exifLatitude = [AppModel sharedAppModel].playerLocation.coordinate.latitude;
    CLLocationDegrees exifLongitude = [AppModel sharedAppModel].playerLocation.coordinate.longitude;
	
    NSString* datetime = [dateFormatter stringFromDate:[AppModel sharedAppModel].playerLocation.timestamp];
	
    [exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    [exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
	
    [locDict setObject:[AppModel sharedAppModel].playerLocation.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
	
    if (exifLatitude <0.0){
        exifLatitude = exifLatitude*(-1);
        [locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }else{
        [locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
	
    if (exifLongitude <0.0){
        exifLongitude=exifLongitude*(-1);
        [locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }else{
        [locDict setObject:@"E" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*) kCGImagePropertyGPSLongitude];
	
    NSDictionary * properties = [[NSDictionary alloc] initWithObjectsAndKeys:
								 locDict, (NSString*)kCGImagePropertyGPSDictionary,
								 exifDict, (NSString*)kCGImagePropertyExifDictionary, nil];
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newJPEGData, CGImageSourceGetType(img), 1, NULL);
    CGImageDestinationAddImageFromSource(dest, img, 0, (__bridge CFDictionaryRef)properties);
    CGImageDestinationFinalize(dest);
	
    CFRelease(img);
    CFRelease(dest);
	
    return newJPEGData;
}


@end
