//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "ARISViewController.h"

@class Note;
@protocol NoteEditorViewControllerDelegate
@end

@interface NoteEditorViewController : ARISViewController
- (id) initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d;
@end
