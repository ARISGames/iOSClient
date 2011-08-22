//
//  NoteViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "TitleAndDecriptionFormViewController.h"


@interface NoteViewController : UIViewController <UITextViewDelegate>{
    IBOutlet UITextView *textBox;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *hideKeyboardButton;

    Item *note;
    id delegate;
}
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *saveButton;
@property(nonatomic, retain) IBOutlet UIButton *hideKeyboardButton;

@property(nonatomic,retain) Item *note;
@property(nonatomic,retain) id delegate;
- (IBAction)saveButtonTouchAction;
- (void) hideKeyboard;
- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm;
- (void)displayTitleandDescriptionForm;
-(IBAction)hideKeyboardTouchAction;
@end
