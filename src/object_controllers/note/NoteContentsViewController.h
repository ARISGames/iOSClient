//
//  NoteContentsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "ARISViewController.h"
@class Media;
@protocol NoteContentsViewControllerDelegate
- (void) mediaWasSelected:(Media *)m;
@end
@interface NoteContentsViewController : ARISViewController
- (id) initWithNoteContents:(NSArray  *)c delegate:(id<NoteContentsViewControllerDelegate>)d;
- (void) setContents:(NSArray *)c;
@end
