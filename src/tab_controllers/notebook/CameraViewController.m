//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "CameraViewController.h"
#import "ARISAlertHandler.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <ImageIO/ImageIO.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIImage+Scale.h"
#import "UIImage+Resize.h"
#import "UIImage+fixOrientation.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"

@interface CameraViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString *presentMode;
    id<CameraViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) NSString *presentMode;

@end

@implementation CameraViewController

@synthesize presentMode;

- (id) initWithPresentMode:(NSString *)mode delegate:(id<CameraViewControllerDelegate>)d;
{
    if((self = [super initWithNibName:@"CameraViewController" bundle:nil]))
    {
        delegate = d;
        
        self.presentMode = mode;
        self.title = NSLocalizedString(@"CameraTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"cameraTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"cameraTabBarSelected"]];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    if(self.presentMode)
    {
        if([self.presentMode isEqualToString:@"camera"])  [self presentCamera];
        if([self.presentMode isEqualToString:@"library"]) [self presentLibrary];
    }
    self.presentMode = nil;
}

- (void) presentCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
    [self presentViewController:picker animated:NO completion:nil];
}

- (void) presentLibrary
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:NO completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    [aPicker dismissViewControllerAnimated:NO completion:nil];

	NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if([mediaType isEqualToString:@"public.image"])
    {        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //PHIL- BS attempt to fix orientation. Don't think it's really needed.
        image = [image fixOrientation];
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size interpolationQuality:kCGInterpolationHigh];
        if(image.size.height > image.size.width)
        {
            if(image.size.height > 856) image = [image scaleToSize:CGSizeMake(image.size.width*(856/image.size.height), 856)];
            if(image.size.width  > 640) image = [image scaleToSize:CGSizeMake(640, image.size.height*(640/image.size.width))];
        }
        else
        {
            if(image.size.width  > 856) image = [image scaleToSize:CGSizeMake(856, image.size.height*(856/image.size.width))];
            if(image.size.height > 640) image = [image scaleToSize:CGSizeMake(image.size.width*(640/image.size.height), 640)];
        }
        //PHIL end BS attempt
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@image.jpg",[NSDate date]]]];
        [imageData writeToURL:imageURL atomically:YES];
        
        // If image not selected from camera roll, save image with metadata to camera roll
        if([info objectForKey:UIImagePickerControllerReferenceURL] == NULL)
        {
            ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
            [al writeImageDataToSavedPhotosAlbum:imageData metadata:nil
                completionBlock:^(NSURL *assetURL, NSError *error)
                {
                    [al assetForURL:assetURL resultBlock:^(ALAsset *asset)
                    {
                        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                        NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
                        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@image.jpg",[NSDate date]]]];
                        [imageData writeToURL:imageURL atomically:YES];
                        [delegate imageChosenWithURL:imageURL];
                        [self.navigationController popViewControllerAnimated:NO];
                    }
                    failureBlock:^(NSError *error)
                    {
                        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:@"Warning" message:@"Your privacy settings are disallowing us from saving to your camera roll. Go into System Settings to turn these settings off."];
                        [delegate imageChosenWithURL:imageURL];
                        [self.navigationController popViewControllerAnimated:NO];
                    }];
            }];
        }
        else
        {
            // image from camera roll
            [delegate imageChosenWithURL:imageURL];
            [self.navigationController popViewControllerAnimated:NO];
        }
	}
	else if([mediaType isEqualToString:@"public.movie"])
    {
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];        
        [delegate videoChosenWithURL:videoURL];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
        [self.navigationController popViewControllerAnimated:NO]; //shouldn't get here, but if it does we at least need to get back
}

- (void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"Error Saving Image: %@", error);
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)aPicker
{
    [aPicker dismissViewControllerAnimated:NO completion:nil];
    [delegate cameraViewControllerCancelled];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
