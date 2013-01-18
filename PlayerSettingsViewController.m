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
//@synthesize playerPicOpt1;
//@synthesize playerPicOpt2;
//@synthesize playerPicOpt3;
@synthesize playerPicCam;

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
    //playerPicOpt1.delegate = self;
    //playerPicOpt2.delegate = self;
    //playerPicOpt3.delegate = self;
    playerPicCam.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshViewFromModel];
}

- (void)manuallyForceViewDidAppear
{
    //Due to the way we hide/show views rather than push/popping them, 'viewDidAppear' was constantly being called even when it wasn't 'actually' appearing.
    //Now, we just call this manually whenever we intend the view to appear.
    self.playerNameField.text = @"";
    if([AppModel sharedAppModel].displayName && ![[AppModel sharedAppModel].displayName isEqualToString:@""])
        self.playerNameField.text = [AppModel sharedAppModel].displayName;
    if([self.playerNameField.text isEqualToString:@""])
       [self.playerNameField becomeFirstResponder];
}

- (void) refreshViewFromModel
{
    if(![[AppModel sharedAppModel].displayName isEqualToString:@""] &&
       !([AppModel sharedAppModel].displayName == nil) &&
       [self.playerNameField.text isEqualToString:@""])
        playerNameField.text = [AppModel sharedAppModel].displayName;
    
    if([AppModel sharedAppModel].playerMediaId != 0 &&
       [AppModel sharedAppModel].playerMediaId != -1)
        [self.playerPic loadImageFromMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].playerMediaId]];
    else
        [self.playerPic updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];

    [playerPicCam loadImageFromMedia:[[AppModel sharedAppModel] mediaForMediaId:36]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)playerNameFieldTouched:(id)sender
{
    return;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(id)playerPicOptTouched:(id)sender
{
    return nil;
}

-(IBAction)goButtonTouched:(id)sender
{
    if([playerNameField.text isEqualToString:@""] || [AppModel sharedAppModel].playerMediaId == 0)
    {
        return;
    }
    
    self.parentViewController.view.hidden = true;
    
    [AppModel sharedAppModel].displayName = playerNameField.text;
    if([playerPic.media.uid intValue]!= 0)
        [AppModel sharedAppModel].playerMediaId = [playerPic.media.uid intValue];
    [[AppServices sharedAppServices] updatePlayer:[AppModel sharedAppModel].playerId Name:playerNameField.text Image:[playerPic.media.uid intValue]];
    [[AppModel sharedAppModel] saveUserDefaults];
    playerNameField.text = @"";

    
    if([AppModel sharedAppModel].skipGameDetails)
    {
        [AppModel sharedAppModel].skipGameDetails = NO;
        
        [AppModel sharedAppModel].currentGame.hasBeenPlayed = YES;
        [AppModel sharedAppModel].inGame = YES;
        [AppServices sharedAppServices].currentlyInteractingWithObject = YES;
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[AppModel sharedAppModel].currentGame
                                                               forKey:@"game"];
        
        [[AppServices sharedAppServices] silenceNextServerUpdate];
        NSNotification *gameSelectNotification = [NSNotification notificationWithName:@"SelectGame" object:self userInfo:dictionary];
        [[NSNotificationCenter defaultCenter] postNotification:gameSelectNotification];
    }
    return;
}

-(void)asyncMediaImageTouched:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
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
                    playerPic.image = image;
                    
                    [imageData writeToURL:imageURL atomically:YES];
                    
                    [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentwithType:kNoteContentTypePhoto withFileURL:imageURL];
                    playerPic.media.uid = 0;
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"PlayerSettingsViewController Error: %@",[error localizedDescription]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: @"Player Pic Upload Failed. Please Try Again." delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
                
                [alert show];
            }];
        }];
    }
    else
    {
        // image from camera roll
        [[[AppModel sharedAppModel] uploadManager] uploadPlayerPicContentwithType:kNoteContentTypePhoto withFileURL:imageURL];
    }
}

@end