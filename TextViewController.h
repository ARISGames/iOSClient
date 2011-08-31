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
    IBOutlet UIButton *keyboardButton;
    NSString *textToDisplay;
    int noteId;
    BOOL editMode;
    BOOL previewMode;

    int contentId;
}
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *saveButton;
@property(nonatomic, retain) IBOutlet UIButton *keyboardButton;
@property(nonatomic,retain)NSString *textToDisplay;
@property(readwrite, assign) int noteId;
@property(readwrite, assign) int contentId;

@property(readwrite,assign)BOOL editMode;
@property(readwrite,assign)BOOL previewMode;

- (IBAction)saveButtonTouchAction;
- (IBAction) hideKeyboard;
-(void)updateContentTouchAction;
@end
