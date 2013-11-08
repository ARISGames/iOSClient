//
//  NoteContentsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "ARISViewController.h"
@protocol NoteContentsViewControllerDelegate
@end
@interface NoteContentsViewController : ARISViewController
- (id) initWithNoteContents:(NSArray  *)c delegate:(id<NoteContentsViewControllerDelegate>)d;
- (void) setContents:(NSArray *)c;
@end
