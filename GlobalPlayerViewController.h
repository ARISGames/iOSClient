//
//  GlobalPlayerViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "AsyncMediaTouchableImageView.h"

@interface GlobalPlayerViewController : UIViewController <AsyncMediaImageViewDelegate> {
	IBOutlet AsyncMediaImageView *playerPic;
    IBOutlet UITextField *playerNameField;
    
    //Not IBOutlets because event listeners are defined outside of the xib
	AsyncMediaTouchableImageView *playerPicOpt1;
	AsyncMediaTouchableImageView *playerPicOpt2;
    AsyncMediaTouchableImageView *playerPicOpt3;
	AsyncMediaTouchableImageView *playerPicCam;

    IBOutlet UIButton *goButton;
}

@property (nonatomic) IBOutlet AsyncMediaImageView *playerPic;
@property (nonatomic) IBOutlet UITextField *playerNameField;

@property (nonatomic) AsyncMediaTouchableImageView *playerPicOpt1;
@property (nonatomic) AsyncMediaTouchableImageView *playerPicOpt2;
@property (nonatomic) AsyncMediaTouchableImageView *playerPicOpt3;
@property (nonatomic) AsyncMediaTouchableImageView *playerPicCam;

-(IBAction)playerNameFieldTouched:(id)sender;
-(id)playerPicOptTouched:(id)sender;
-(IBAction)goButtonTouched:(id)sender;

-(void)asyncMediaImageTouched:(id)sender;

@end
