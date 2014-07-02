//
//  NoteViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "InstantiableViewController.h"

@class Note;
@protocol NoteViewControllerDelegate
@end

@interface NoteViewController : InstantiableViewController
- (id) initWithNote:(Note *)n delegate:(id<InstantiableViewControllerDelegate, NoteViewControllerDelegate>)d;
@end
