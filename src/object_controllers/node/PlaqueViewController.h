//
//  PlaqueViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstantiableViewController.h"

@protocol StateControllerProtocol;
@class Instance;
@interface PlaqueViewController : InstantiableViewController
- (id) initWithInstance:(Instance *)i delegate:(id<InstantiableViewControllerDelegate, StateControllerProtocol>)d;
@end
