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

@interface NoteCameraViewController : UIViewController
- (id) initWithDelegate:(id<NoteCameraViewControllerDelegate>)d;
@end
