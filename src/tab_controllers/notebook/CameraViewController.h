//
//  CameraViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewControllerDelegate
- (void) imageChosenWithURL:(NSURL *)url;
- (void) videoChosenWithURL:(NSURL *)url;
- (void) cameraViewControllerCancelled;
@end

@interface CameraViewController : UIViewController
- (id) initWithPresentMode:(NSString *)mode delegate:(id<CameraViewControllerDelegate>)d;
@end
