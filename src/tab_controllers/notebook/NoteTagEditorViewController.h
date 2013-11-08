//
//  NoteTagEditorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "ARISViewController.h"
@protocol NoteTagEditorViewControllerDelegate
@end

@interface NoteTagEditorViewController : ARISViewController
- (id) initWithTags:(NSArray *)t delegate:(id<NoteTagEditorViewControllerDelegate>)d;
@end
