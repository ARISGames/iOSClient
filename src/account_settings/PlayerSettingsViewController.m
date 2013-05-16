//
//  PlayerSettingsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//

#import "PlayerSettingsViewController.h"
#import "AppServices.h"

@interface PlayerSettingsViewController()
{
    IBOutlet AsyncMediaImageView *playerPic;
    IBOutlet UITextField *playerNameField;
	IBOutlet UIButton *playerPicCamButton;
    IBOutlet UIButton *saveButton;
    
    NSString *chosenName;
    int chosenMediaId;
    
    id<PlayerSettingsViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic) IBOutlet AsyncMediaImageView *playerPic;
@property (nonatomic) IBOutlet UITextField *playerNameField;
@property (nonatomic) IBOutlet UIButton *playerPicCamButton;
@property (nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)saveButtonTouched:(id)sender;
- (IBAction)playerPicCamButtonTouched:(id)sender;

@end

@implementation PlayerSettingsViewController

@synthesize playerPic;
@synthesize playerNameField;
@synthesize playerPicCamButton;
@synthesize saveButton;

- (id)initWithDelegate:(id<PlayerSettingsViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"PlayerSettingsViewController" bundle:nil])
    {
        delegate = d;
        
        //chosenName = nil;
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
    [self.playerPic updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
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
        [self.playerPic loadMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId]];
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
        //PHIL [[RootViewController sharedRootViewController] showAlert:nil message:@"Please choose a picture and name"];
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
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        
        UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(40, 390, 300, 33)];
        instructions.backgroundColor = [UIColor clearColor];
        instructions.textColor = [UIColor whiteColor];
        instructions.text = NSLocalizedString(@"TakeYourPictureKey", @"");
        
        [picker.view addSubview:instructions];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        else
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.allowsEditing = YES;
        picker.showsCameraControls = YES;
        [self presentModalViewController:picker animated:NO];
    }

    return;
}

- (void) imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    chosenMediaId = -1;
    [aPicker dismissModalViewControllerAnimated:NO];

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
                playerPic.image = image;
            } failureBlock:^(NSError *error) {
                [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
                playerPic.image = image;
            }];
        }];
    }
    else
    {
        // image from camera roll
        [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
        playerPic.image = image;
    }
}

@end