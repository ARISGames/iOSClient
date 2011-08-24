//
//  NoteViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface TextViewController : UIViewController <UITextViewDelegate>{
    IBOutlet UITextView *textBox;
    IBOutlet UIButton *saveButton;
    int noteId;
}
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *saveButton;
@property(readwrite, assign) int noteId;
- (IBAction)saveButtonTouchAction;
- (void) hideKeyboard;

@end
