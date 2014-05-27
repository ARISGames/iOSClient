//
//  PlayerSettingsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//

#import "PlayerSettingsViewController.h"
#import "AppServices.h"
#import "ARISMediaView.h"
#import "ARISAlertHandler.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "User.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIImage+Scale.h"
#import <ImageIO/ImageIO.h>

@interface PlayerSettingsViewController()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ARISMediaViewDelegate, UITextFieldDelegate>
{
    IBOutlet ARISMediaView *playerPic;
    IBOutlet UITextField *playerNameField;
    int chosenMediaId;
    
    id<PlayerSettingsViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic) IBOutlet ARISMediaView *playerPic;
@property (nonatomic) IBOutlet UITextField *playerNameField;

- (IBAction) saveButtonTouched:(id)sender;
- (IBAction) playerPicCamButtonTouched:(id)sender;

@end

@implementation PlayerSettingsViewController

@synthesize playerPic;
@synthesize playerNameField;

- (id)initWithDelegate:(id<PlayerSettingsViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"PlayerSettingsViewController" bundle:nil])
    {
        delegate = d;
        chosenMediaId = 0;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.title = NSLocalizedString(@"PublicNameAndImageKey", @"");
}

- (void) viewDidAppear:(BOOL)animated
{    
    [self refreshView];
}

- (void) resetState
{
    self.playerNameField.text = @"";
    chosenMediaId = 0;
    [self.playerPic setImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
}

- (void) syncLocalVars
{
    if([self.playerNameField.text isEqualToString:@""])
        self.playerNameField.text = _MODEL_PLAYER_.display_name; // @"" by default
    if(chosenMediaId == 0)
        chosenMediaId = _MODEL_PLAYER_.media_id;
}

- (void) refreshView
{
    [self syncLocalVars];
    
    if([self.playerNameField.text isEqualToString:@""])
        [self.playerNameField becomeFirstResponder];

    if(chosenMediaId > 0)
        [self.playerPic setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id]];
    else if(chosenMediaId == 0)
        [self takePicture];
    //if chosenMediaId < 0, just leave the image as is
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [playerNameField resignFirstResponder];
}

- (IBAction) saveButtonTouched:(id)sender
{
    if([self.playerNameField.text isEqualToString:@""] || chosenMediaId == 0)
    {
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ProfileSaveErrorKey", @"") message:NSLocalizedString(@"ProfileSaveErrorMessageKey", @"")];
        return;
    }

    _MODEL_PLAYER_.display_name = playerNameField.text; //Let AppServices take care of setting AppModel's Media id

    //[_SERVICES_ updatePlayer:_MODEL_PLAYER_.user_id withName:_MODEL_PLAYER_.display_name];

    [delegate playerSettingsWasDismissed];
}

- (IBAction) playerPicCamButtonTouched:(id)sender
{
    [self takePicture];
}

- (void) takePicture
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 300, 33)];
        instructions.backgroundColor = [UIColor clearColor];
        instructions.textColor = [UIColor whiteColor];
        instructions.text = NSLocalizedString(@"TakeYourPictureKey", @"");
        
        [picker.view addSubview:instructions];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        else
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.allowsEditing = YES;
        picker.showsCameraControls = YES;
        [self presentViewController:picker animated:NO completion:nil];
    }

    return;
}

- (void) imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    chosenMediaId = -1;
    [aPicker dismissViewControllerAnimated:NO completion:nil];

    UIImage *image = [[info objectForKey:UIImagePickerControllerEditedImage] scaleToSize:CGSizeMake(1024,1024)];

    // If image not selected from camera roll, save image with metadata to camera roll
    if([info objectForKey:UIImagePickerControllerReferenceURL] == NULL)
    {
        ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
        [al writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(image, 1.0) metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            // once image is saved, get asset from assetURL
            [al assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                // save image to temporary directory to be able to upload it
                [self uploadImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]]];
            } failureBlock:^(NSError *error) {
                [self uploadImage:image]; 
            }];
        }];
    }
    else
    {
        [self uploadImage:image];  
    }
}

- (void) uploadImage:(UIImage *)i
{
    //Save to tmp dir
    NSData *imageData = UIImageJPEGRepresentation(i, 0.4);
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd_MM_yyyy_HH_mm"];
    NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@_image.jpg", [outputFormatter stringFromDate:[NSDate date]]]]]; 
    [imageData writeToURL:imageURL atomically:YES]; 
    
    Media *m = [_MODEL_MEDIA_ newMedia];
    m.localURL = imageURL;
    m.data = imageData; 
    [self.playerPic setImage:i]; 
    //[_SERVICES_ uploadPlayerPic:m];
}

@end
