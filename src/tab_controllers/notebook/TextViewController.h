//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface TextViewController : UIViewController <UITextViewDelegate>{
    IBOutlet UITextView *textBox;
    IBOutlet UIButton *keyboardButton;
    NSString *textToDisplay;
    int noteId;
    BOOL editMode;
    BOOL previewMode;
    id __unsafe_unretained backView;
    id __unsafe_unretained editView;
    int contentId;
    int index;
}
@property(nonatomic) IBOutlet UITextView *textBox;
@property(nonatomic) IBOutlet UIButton *keyboardButton;
@property(nonatomic, unsafe_unretained) id backView;
@property(nonatomic, unsafe_unretained) id editView;

@property(nonatomic)NSString *textToDisplay;
@property(readwrite, assign) int noteId;
@property(readwrite, assign) int contentId;
@property(readwrite,assign)int index;

@property(readwrite,assign)BOOL editMode;
@property(readwrite,assign)BOOL previewMode;

- (IBAction)saveButtonTouchAction;
- (IBAction) hideKeyboard;
-(void)updateContentTouchAction;
@end
