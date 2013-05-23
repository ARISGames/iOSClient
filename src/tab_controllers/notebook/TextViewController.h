//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;
@class NoteContent;
@protocol TextViewControllerDelegate
- (void) textChosen:(NSString *)s;
- (void) textUpdated:(NSString *)s forContent:(NoteContent *)c;
- (void) textViewControllerCancelled;
@end

@interface TextViewController : UIViewController
- (id) initWithNote:(Note *)n content:(NoteContent *)c inMode:(NSString *)m delegate:(id<TextViewControllerDelegate>)d;
@end
