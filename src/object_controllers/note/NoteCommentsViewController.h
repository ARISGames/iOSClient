//
//  NoteCommentsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 12/10/13.
//
//

#import <UIKit/UIKit.h>

@protocol NoteCommentsViewControllerDelegate
@end

@interface NoteCommentsViewController : UIViewController
- (id) initWithNoteComments:(NSArray *)c delegate:(id<NoteCommentsViewControllerDelegate>)d;
- (void) setComments:(NSArray *)c;
@end
