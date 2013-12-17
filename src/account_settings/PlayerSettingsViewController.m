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
#import "Player.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIImage+Scale.h"
#import "UploadMan.h"
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

- (IBAction)saveButtonTouched:(id)sender;
- (IBAction)playerPicCamButtonTouched:(id)sender;

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
    self.title = @"Public Name and Image";
}

- (void) viewDidAppear:(BOOL)animated
{    
    [self refreshView];
}

- (void) resetState
{
    self.playerNameField.text = @"";
    chosenMediaId = 0;
    [self.playerPic refreshWithFrame:self.playerPic.frame image:[UIImage imageNamed:@"DefaultPCImage.png"] mode:ARISMediaDisplayModeAspectFill delegate:self];
}

- (void) syncLocalVars
{
    if([self.playerNameField.text isEqualToString:@""])
        self.playerNameField.text = [AppModel sharedAppModel].player.displayname; // @"" by default
    if(chosenMediaId == 0)
        chosenMediaId = [AppModel sharedAppModel].player.playerMediaId;
}

- (void) refreshView
{
    [self syncLocalVars];
    
    if([self.playerNameField.text isEqualToString:@""])
        [self.playerNameField becomeFirstResponder];

    if(chosenMediaId > 0)
        [self.playerPic refreshWithFrame:self.playerPic.frame media:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId] mode:ARISMediaDisplayModeAspectFill delegate:self];
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
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:@"Profile Save Error" message:@"Please choose a picture and name"];
        return;
    }

    [AppModel sharedAppModel].player.displayname = playerNameField.text; //Let AppServices take care of setting AppModel's Media id

    [[AppServices sharedAppServices] updatePlayer:[AppModel sharedAppModel].player.playerId
                                         withName:[AppModel sharedAppModel].player.displayname
                                         andImage:[AppModel sharedAppModel].player.playerMediaId];

    [[AppModel sharedAppModel] saveUserDefaults];

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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
    NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@image.jpg",[NSDate date]]]];
    [imageData writeToURL:imageURL atomically:YES];

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
                    
                [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
                [self.playerPic refreshWithFrame:playerPic.frame image:image mode:ARISMediaDisplayModeAspectFill delegate:self];
            } failureBlock:^(NSError *error) {
                [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
                [self.playerPic refreshWithFrame:playerPic.frame image:image mode:ARISMediaDisplayModeAspectFill delegate:self];
            }];
        }];
    }
    else
    {
        // image from camera roll
        [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
        [self.playerPic refreshWithFrame:playerPic.frame image:image mode:ARISMediaDisplayModeAspectFill delegate:self];
    }
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

@end