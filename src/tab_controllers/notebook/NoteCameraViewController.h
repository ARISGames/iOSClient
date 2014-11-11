//
//  NoteCameraViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 12/11/13.
//
//

#import <UIKit/UIKit.h>

@protocol NoteCameraViewControllerDelegate
- (void) imageChosenWithURL:(NSURL *)url;
- (void) videoChosenWithURL:(NSURL *)url;
- (void) cameraViewControllerCancelled;
@end

typedef enum
{
    NOTE_CAMERA_MODE_CAMERA,
    NOTE_CAMERA_MODE_ROLL,
    NOTE_CAMERA_MODE_NONE
} NoteCameraMode;


@interface NoteCameraViewController : UIViewController
- (id) initWithMode:(NoteCameraMode)m delegate:(id<NoteCameraViewControllerDelegate>)d;
@end
