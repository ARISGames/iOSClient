//
//  NoteCameraViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 12/11/13.
//

#import "NoteCameraViewController.h"
#import "UIImage+Scale.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ARISAlertHandler.h"

@interface NoteCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    id<NoteCameraViewControllerDelegate> __unsafe_unretained delegate;
    UIImagePickerController *picker;
    UIButton *rollButton;
    UIButton *backButton;
} 
@end

@implementation NoteCameraViewController

- (id) initWithDelegate:(id<NoteCameraViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"CameraTitleKey",@"");
        delegate = d;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self presentCamera];
}

- (void) presentCamera
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType]; 
    picker.allowsEditing = NO;
	picker.showsCameraControls = YES;
    
    rollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rollButton.frame = CGRectMake(20, 30, 65, 65);
    [rollButton addTarget:self action:@selector(showLibrary) forControlEvents:UIControlEventTouchDown];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 33, 80, 20);
    [backButton setTitle:NSLocalizedString(@"BackButtonKey", @"") forState:UIControlStateNormal];
    [backButton setTitleColor:[[[[UIApplication sharedApplication] delegate] window] tintColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchDown];
    
    //get the last image from the roll
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop){
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                *stop = YES;
                *innerStop = YES;
                [rollButton setImage:latestPhoto forState:UIControlStateNormal];
            }
        }];
    }failureBlock:^(NSError *error){
        NSLog(@"NO GROUPS!");
    }];
    
    [picker.view addSubview:rollButton];
    [self presentViewController:picker animated:NO completion:nil];
}

- (void) showLibrary
{
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [rollButton removeFromSuperview];
    [picker.view addSubview:backButton];
}

- (void) showCamera
{
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [backButton removeFromSuperview];
    [picker.view addSubview:rollButton];
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
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"dd_MM_yyyy_HH_mm"];
        
        NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@_image.jpg", [outputFormatter stringFromDate:[NSDate date]]]]];
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
                  }
                    failureBlock:^(NSError *error)
                  {
                      //doesn't exist, save to roll failed
                      [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"CameraWarningKey", @"") message:NSLocalizedString(@"CameraWarningMessageKey", @"")];
                      [delegate imageChosenWithURL:imageURL];
                  }];
             }];
        }
        else
        {
            // image from camera roll
            [delegate imageChosenWithURL:imageURL];
        }
	}
	else if([mediaType isEqualToString:@"public.movie"])
    {
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];        
        [delegate videoChosenWithURL:videoURL];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)aPicker
{
    [aPicker dismissViewControllerAnimated:NO completion:nil];
    [delegate cameraViewControllerCancelled]; 
}

@end

