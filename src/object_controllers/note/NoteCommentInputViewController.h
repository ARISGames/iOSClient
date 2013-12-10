//
//  NoteCommentInputViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 12/10/13.
//
//

#import <UIKit/UIKit.h>

@protocol NoteCommentInputViewControllerDelegate
- (void) commentBeganEditing;
- (void) commentCancelled;
- (void) commentConfirmed:(NSString *)c;
@end
@interface NoteCommentInputViewController : UIViewController
- (id)initWithDelegate:(id<NoteCommentInputViewControllerDelegate>)d;
@end
