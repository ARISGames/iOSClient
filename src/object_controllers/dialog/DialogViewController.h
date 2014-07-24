//
//  DialogViewController.h
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstantiableViewController.h"

@protocol StateControllerProtocol;
@class Instance;
@interface DialogViewController : InstantiableViewController
- (id) initWithInstance:(Instance *)i delegate:(id<InstantiableViewControllerDelegate, StateControllerProtocol>)d;
@end
