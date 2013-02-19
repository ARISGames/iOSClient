//
//  PlayerSettingsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//

#import "PlayerSettingsViewController.h"
#import "AppServices.h"

@implementation PlayerSettingsViewController

@synthesize playerPic;
@synthesize playerNameField;
@synthesize playerPicCamButton;
@synthesize saveButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshViewFromModel];
    self.title = @"Public Name and Image";
}

- (void)manuallyForceViewDidAppear
{
    //Due to the way we hide/show views rather than push/popping them, 'viewDidAppear' was constantly being called even when it wasn't 'actually' appearing.
    //Now, we just call this manually whenever we intend the view to appear. //<- This is a call for refactor (ps I wrote this code so I'm calling myself out) - Phil
    self.playerNameField.text = @"";
    if([AppModel sharedAppModel].displayName && ![[AppModel sharedAppModel].displayName isEqualToString:@""])
        self.playerNameField.text = [AppModel sharedAppModel].displayName;
    if([self.playerNameField.text isEqualToString:@""])
       [self.playerNameField becomeFirstResponder];
}

- (void) refreshViewFromModel
{
    if([AppModel sharedAppModel].displayName && ![[AppModel sharedAppModel].displayName isEqualToString:@""] &&
       [self.playerNameField.text isEqualToString:@""])
        playerNameField.text = [AppModel sharedAppModel].displayName;
    
    if([AppModel sharedAppModel].playerMediaId > 0)
        [self.playerPic loadImageFromMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].playerMediaId]];
    else
        [self.playerPic updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)saveButtonTouched:(id)sender
{
    if([self.playerNameField.text isEqualToString:@""] || [AppModel sharedAppModel].playerMediaId == 0)
    {
        [[RootViewController sharedRootViewController] showAlert:nil message:@"Please choose a picture and name"];
        return;
    }
    
    self.parentViewController.view.hidden = true;
    
    [AppModel sharedAppModel].displayName = playerNameField.text;
    self.playerNameField.text = @"";

    if([self.playerPic.media.uid intValue] != 0)
        [AppModel sharedAppModel].playerMediaId = [playerPic.media.uid intValue];
    [self.playerPic updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
    
    [[AppServices sharedAppServices] updatePlayer:[AppModel sharedAppModel].playerId
                                         withName:[AppModel sharedAppModel].displayName
                                         andImage:[AppModel sharedAppModel].playerMediaId];
    
    [[AppModel sharedAppModel] saveUserDefaults];

    if([AppModel sharedAppModel].skipGameDetails)
    {
        [AppModel sharedAppModel].skipGameDetails = NO;
        
        [AppModel sharedAppModel].currentGame.hasBeenPlayed = YES;
        [AppModel sharedAppModel].inGame = YES;
        [AppModel sharedAppModel].currentlyInteractingWithObject = YES;
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[AppModel sharedAppModel].currentGame
                                                               forKey:@"game"];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelectGame" object:self userInfo:dictionary]];
    }
    return;
}

-(IBAction)playerPicCamButtonTouched:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        
        UILabel *instructions = [[UILabel alloc] initWithFrame:CGRectMake(40, 390, 300, 33)];
        instructions.backgroundColor = [UIColor clearColor];
        instructions.textColor = [UIColor whiteColor];
        instructions.text = NSLocalizedString(@"TakeYourPictureKey", @"");
/*
        UIImageView *overlay = [[UIImageView alloc] initWithFrame:picker.view.bounds];
        overlay.image = ;
        // tell the view to put the image at the top, and make it translucent
        overlay.contentMode = UIViewContentModeTop;
        overlay.alpha = 0.5f;
        picker.cameraOverlayView = overlay;
*/
        
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

-(void) imageFinishedLoading{
    return;
}

- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary  *)info
{
    [AppModel sharedAppModel].playerMediaId = -1; //Non-Zero (so we know it's picked, but it hasn't been assigned an ID yet)
    [aPicker dismissModalViewControllerAnimated:NO];

    UIImage *image;
    NSString *mediaFilePath;
    NSURL *imageURL;
    NSData *mediaData;

    image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [image scaleToSize:CGSizeMake(1024,1024)];
    mediaFilePath =[NSTemporaryDirectory() stringByAppendingString: [NSString stringWithFormat:@"%@image.jpg",[NSDate date]]];
    imageURL = [[NSURL alloc] initFileURLWithPath:mediaFilePath];
    mediaData = UIImageJPEGRepresentation(image, 0.4);
    if (mediaData != nil) [mediaData writeToURL:imageURL atomically:YES];

    // If image not selected from camera roll, save image with metadata to camera roll
    if ([info objectForKey:UIImagePickerControllerReferenceURL] == NULL)
    {
        ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
        [al writeImageDataToSavedPhotosAlbum:mediaData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {                        
            // once image is saved, get asset from assetURL
            [al assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    // save image to temporary directory to be able to upload it
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    CGImageRef iref = [rep fullResolutionImage];
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
                    NSString *newFilePath =[NSTemporaryDirectory() stringByAppendingString: [NSString stringWithFormat:@"%@image.jpg",[NSDate date]]];
                    NSURL *imageURL = [[NSURL alloc] initFileURLWithPath: newFilePath];
                    
                    [imageData writeToURL:imageURL atomically:YES];
                    
                    [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
                    playerPic.image = image;
                    playerPic.media.uid = 0;
                    
                }
            } failureBlock:^(NSError *error) {
                [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
                playerPic.image = image;
                playerPic.media.uid = 0;
            }];
        }];
    }
    else
    {
        // image from camera roll
        [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentWithFileURL:imageURL];
        playerPic.image = image;
        playerPic.media.uid = 0;
    }
}

@end