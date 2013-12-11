//
//  NoteCameraViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 12/11/13.
//
//

#import "NoteCameraViewController.h"
#import "UIImage+Scale.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ARISAlertHandler.h"

@interface NoteCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    id<NoteCameraViewControllerDelegate> __unsafe_unretained delegate;
} 
@end

@implementation NoteCameraViewController

- (id) initWithDelegate:(id<NoteCameraViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"CameraTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"cameraTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"cameraTabBarSelected"]]; 
        delegate = d;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) presentCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType]; 
    picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
    [self presentViewController:picker animated:NO completion:nil];
}

- (void) presentLibrary
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType]; 
    
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
        //image = [image fixOrientation];
        //image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size interpolationQuality:kCGInterpolationHigh];
        //PHIL end BS attempt 
        
        //Aspect fit
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
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@image.jpg",[NSDate date]]]];
        [imageData writeToURL:imageURL atomically:YES];
        
        // If image not selected from camera roll, save image with metadata to camera roll
        if([info objectForKey:UIImagePickerControllerReferenceURL] == NULL)
        {
            ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
            //save to role
            [al writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 //get from role to see if it exists
                 [al assetForURL:assetURL resultBlock:^(ALAsset *asset)
                  {
                      //exists, save to roll worked
                      [delegate imageChosenWithURL:imageURL];
                      [self.navigationController popViewControllerAnimated:NO];
                  }
                    failureBlock:^(NSError *error)
                  {
                      //doesn't exist, save to roll failed
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

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)aPicker
{
    [aPicker dismissViewControllerAnimated:NO completion:nil];
    [delegate cameraViewControllerCancelled];
    [self.navigationController popViewControllerAnimated:NO];
}

@end

