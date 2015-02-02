//
//  PlayerSettingsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//

#import "PlayerSettingsViewController.h"
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
    ARISMediaView *playerPic;
    UITextField *playerNameField;
    long chosenMediaId;
    
    UIButton *saveButton;
    UIButton *cameraButton;
    
    id<PlayerSettingsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation PlayerSettingsViewController

- (id) initWithDelegate:(id<PlayerSettingsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"PublicNameAndImageKey", @"");
        chosenMediaId = 0;
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    playerNameField = [[UITextField alloc] init];
    playerNameField.delegate = self;
    playerNameField.textAlignment = NSTextAlignmentCenter;
    
    playerPic = [[ARISMediaView alloc] init];
    [playerPic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picTouched)]];
    playerPic.userInteractionEnabled = YES;
    playerPic.backgroundColor = [UIColor blackColor];
    
    cameraButton = [[UIButton alloc] init];
    [cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    saveButton = [[UIButton alloc] init];
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
    
    [self.view addSubview:playerNameField];
    [self.view addSubview:playerPic];
    [self.view addSubview:cameraButton];
    [self.view addSubview:saveButton];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    playerNameField.frame = CGRectMake(0,74,self.view.frame.size.width,20);
    playerPic.frame = CGRectMake(0,playerNameField.frame.origin.y+playerNameField.frame.size.height+10,self.view.frame.size.width,self.view.frame.size.width);
    
    cameraButton.frame = CGRectMake(10, self.view.frame.size.height-30, 100, 20);
    saveButton.frame = CGRectMake(self.view.frame.size.width-110, self.view.frame.size.height-30, 100, 20);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{    
    [super viewDidAppear:animated];
    [self refreshView];
}

- (void) resetState
{
    playerNameField.text = @"";
    chosenMediaId = 0;
    [playerPic setImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
}

- (void) refreshView
{
    //take on values from model
    if([playerNameField.text isEqualToString:@""]) playerNameField.text = _MODEL_PLAYER_.display_name; // @"" by default
    if(chosenMediaId == 0)                         chosenMediaId = _MODEL_PLAYER_.media_id;
    
    if([playerNameField.text isEqualToString:@""]) [playerNameField becomeFirstResponder];

    if(chosenMediaId > 0)       [playerPic setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id]];
    else if(chosenMediaId == 0) [self takePicture];
    //chosenMediaId < 0 = newly chosen
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) picTouched
{
    [playerNameField resignFirstResponder];
}

- (void) saveButtonTouched
{
    //temporary workaround
    [delegate playerSettingsWasDismissed]; return;
    
    if([playerNameField.text isEqualToString:@""] || chosenMediaId == 0)
    {
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ProfileSaveErrorKey", @"") message:NSLocalizedString(@"ProfileSaveErrorMessageKey", @"")];
        return;
    }

    _MODEL_PLAYER_.display_name = playerNameField.text;
    [_MODEL_ updatePlayerName:playerNameField.text];

    [delegate playerSettingsWasDismissed];
}

- (void) cameraButtonTouched
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
    //short names to cope with obj-c verbosity
    Media *m = [_MODEL_MEDIA_ newMedia];
    NSString *g = @"0"; //game_id as string
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init]; [outputFormatter setDateFormat:@"dd_MM_yyyy_HH_mm"];
    NSString *f = [NSString stringWithFormat:@"%@_image.jpg", [outputFormatter stringFromDate:[NSDate date]]]; //filename
    
    NSString *newFolder = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(g);
    if(![[NSFileManager defaultManager] fileExistsAtPath:newFolder isDirectory:nil])
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];
    [m setPartialLocalURL:[NSString stringWithFormat:@"%@/%@",g,f]];
    
    m.data = UIImageJPEGRepresentation(i, 0.4);
    [m.data writeToURL:m.localURL options:nil error:nil];
    
    [playerPic setImage:i]; 
    [_MODEL_ updatePlayerMedia:m];
}

@end
