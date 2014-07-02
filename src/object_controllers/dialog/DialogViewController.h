//
//  DialogViewController.h
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "InstantiableViewController.h"

@class Dialog;
@protocol StateControllerProtocol;

@interface DialogViewController : InstantiableViewController
- (id) initWithDialog:(Dialog *)n delegate:(id<InstantiableViewControllerDelegate, StateControllerProtocol>)d;
@end
