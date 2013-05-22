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
#import "NotebookViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MapViewController.h"
#import "NoteCommentViewController.h"
#import "NoteEditorViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIImage+Scale.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import <ImageIO/ImageIO.h>

@implementation CameraViewController

@synthesize parentDelegate,backView,showVid, noteId,editView,picker;

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle]))
    {
        self.title = NSLocalizedString(@"CameraTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"camera.png"];
        bringUpCamera = YES;
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    if(bringUpCamera)
    {
        bringUpCamera = NO;

        if(showVid) [self presentCamera];
        else        [self presentLibrary];
    }
}

- (void) presentCamera
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
	[self presentModalViewController:picker animated:NO];
}

- (void) presentLibrary
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
	[self presentModalViewController:picker animated:NO];
}

- (void) imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    [aPicker dismissModalViewControllerAnimated:NO];

	NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if([mediaType isEqualToString:@"public.image"])
    {        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //PHIL- BS attempt to fix orientation. Don't think it's really needed.
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
        //PHIL end BS attempt
        NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@image.jpg",[NSDate date]]]];
        [imageData writeToURL:imageURL atomically:YES];
        
        //PHIL- BS attempt at metadata
        //Image Meta Data
        NSMutableDictionary *newMetadata = [[NSMutableDictionary alloc] initWithDictionary:[info objectForKey:UIImagePickerControllerMediaMetadata]];
        CLLocation * location = [AppModel sharedAppModel].player.location;
        [newMetadata setLocation:location];
        NSString *gameName = [AppModel sharedAppModel].currentGame.name;
        NSString *descript = [[NSString alloc] initWithFormat: @"%@ %@: %@. %@: %@", NSLocalizedString(@"CameraImageTakenKey", @""), NSLocalizedString(@"CameraGameKey", @""), gameName, NSLocalizedString(@"CameraPlayerKey", @""), [AppModel sharedAppModel].player.username];
        [newMetadata setDescription: descript];
        
        //Handle Delegate
        if([self.parentDelegate isKindOfClass:[NoteCommentViewController class]])
            [self.parentDelegate addedPhoto];
        if([self.editView isKindOfClass:[NoteEditorViewController class]])
        {
            [self.editView setNoteValid:YES];
            [self.editView setNoteChanged:YES];
        }
        //PHIL end BS attempt
        
        // If image not selected from camera roll, save image with metadata to camera roll
        if([info objectForKey:UIImagePickerControllerReferenceURL] == NULL)
        {
            ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
            [al writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                // once image is saved, get asset from assetURL
                [al assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    // save image to temporary directory to be able to upload it
                    UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
                    NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@image.jpg",[NSDate date]]]];
                    [imageData writeToURL:imageURL atomically:YES];
                    
                    [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"PHOTO" withFileURL:imageURL];
                    if([self.editView isKindOfClass:[NoteEditorViewController class]])
                        [self.editView refreshViewFromModel];
                    
                } failureBlock:^(NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your privacy settings are disallowing us from saving to your camera roll. Go into System Settings to turn these settings off." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    //Do the upload
                    [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"PHOTO" withFileURL:imageURL];
                    if([self.editView isKindOfClass:[NoteEditorViewController class]])
                        [self.editView refreshViewFromModel];
                }];
            }];
        }
        else
        {
            // image from camera roll
            [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:nil withType:@"PHOTO" withFileURL:imageURL];
            if([self.editView isKindOfClass:[NoteEditorViewController class]])
                [self.editView refreshViewFromModel];
        }
	}
	else if([mediaType isEqualToString:@"public.movie"])
    {
		NSLog(@"CameraViewController: Found a Movie");
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        if([self.parentDelegate isKindOfClass:[NoteCommentViewController class]])
            [self.parentDelegate addedVideo];
        if([self.editView isKindOfClass:[NoteEditorViewController class]])
        {
            [self.editView setNoteValid:YES];
            [self.editView setNoteChanged:YES];
        }
        
        [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@", [NSDate date]] withText:nil withType:@"VIDEO" withFileURL:videoURL];
    }	

    [self.navigationController popViewControllerAnimated:NO];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"Error Saving Image: %@", error);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker
{
    [aPicker dismissModalViewControllerAnimated:NO];
    if([backView isKindOfClass:[NotebookViewController class]])
    {
        [[AppServices sharedAppServices] deleteNoteWithNoteId:self.noteId];
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.noteId]];   
    }
    [self.navigationController popToViewController:self.backView animated:NO];
}

- (NSMutableData*) dataWithEXIFUsingData:(NSData*)originalJPEGData
{
    NSMutableData* newJPEGData = [[NSMutableData alloc] init];
    NSMutableDictionary* exifDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* locDict = [[NSMutableDictionary alloc] init];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
	
    CGImageSourceRef img = CGImageSourceCreateWithData((__bridge CFDataRef)originalJPEGData, NULL);
    CLLocationDegrees exifLatitude  = [AppModel sharedAppModel].player.location.coordinate.latitude;
    CLLocationDegrees exifLongitude = [AppModel sharedAppModel].player.location.coordinate.longitude;
	
    NSString* datetime = [dateFormatter stringFromDate:[AppModel sharedAppModel].player.location.timestamp];
	
    [exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    [exifDict setObject:datetime forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
	
    [locDict setObject:[AppModel sharedAppModel].player.location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
	
    if (exifLatitude <0.0)
    {
        exifLatitude = exifLatitude*(-1);
        [locDict setObject:@"S" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }
    else
    {
        [locDict setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    }
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
	
    if(exifLongitude < 0.0)
    {
        exifLongitude=exifLongitude*(-1);
        [locDict setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    }
    else
    {
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
