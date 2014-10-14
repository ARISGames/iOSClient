//
//  NoteViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "InstantiableViewController.h"

@protocol StateControllerProtocol;
@class Instance;
@interface NoteViewController : InstantiableViewController
- (id) initWithInstance:(Instance *)i delegate:(id<InstantiableViewControllerDelegate, StateControllerProtocol>)d;
@end

