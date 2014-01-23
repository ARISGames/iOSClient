//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "ARISViewController.h"

@class Note;
@class NoteEditorViewController;

@protocol NoteEditorViewControllerDelegate
- (void) noteEditorCancelledNoteEdit:(NoteEditorViewController *)ne;
- (void) noteEditorConfirmedNoteEdit:(NoteEditorViewController *)ne note:(Note *)n;
@end

@interface NoteEditorViewController : ARISViewController
- (id) initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d;
@end
