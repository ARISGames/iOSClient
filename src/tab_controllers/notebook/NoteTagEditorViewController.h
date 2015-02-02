//
//  NoteTagEditorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "ARISViewController.h"

@class Tag;

@protocol NoteTagEditorViewControllerDelegate
- (void) noteTagEditorAddedTag:(Tag *)nt;
- (void) noteTagEditorCancelled;
- (void) noteTagEditorDeletedTag:(Tag *)nt;
- (void) noteTagEditorWillBeginEditing;
@end

@interface NoteTagEditorViewController : ARISViewController
- (id) initWithTag:(Tag *)t editable:(BOOL)e delegate:(id<NoteTagEditorViewControllerDelegate>)d;
- (void) setExpandHeight:(long)h;
- (void) setTag:(Tag *)t;
- (void) beginEditing;
- (void) stopEditing;
@end
