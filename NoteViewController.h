//
//  NoteViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "TitleAndDecriptionFormViewController.h"


@interface NoteViewController : UIViewController <UITextViewDelegate>{
    IBOutlet UITextView *textBox;
    IBOutlet UIButton *saveButton;
    Note *note;
}
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *saveButton;
@property(nonatomic,retain) Note *note;
- (IBAction)saveButtonTouchAction;
- (void) hideKeyboard;
- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm;
- (void)displayTitleandDescriptionForm;
@end
