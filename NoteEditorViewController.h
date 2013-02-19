//
//  NoteEditorViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Note.h"
#import <AVFoundation/AVFoundation.h>


@interface NoteEditorViewController : UIViewController <AVAudioSessionDelegate,UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, AVAudioPlayerDelegate,UIActionSheetDelegate>{
    IBOutlet UITextView *textBox;
    IBOutlet UITextField *textField;
    IBOutlet UIButton *cameraButton;
    IBOutlet UIButton *audioButton;
    IBOutlet UIButton *libraryButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *publicButton;
    IBOutlet UIButton *textButton;
    IBOutlet UIButton *hideKeyboardButton;
    IBOutlet UISegmentedControl *typeControl;
    IBOutlet UITableView *contentTable;
    Note *note;
    id __unsafe_unretained delegate;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    NSMutableDictionary *vidThumbs;
    int pageNumber;
    int numPages;
    id timeObserver;
    BOOL noteValid, noteChanged, noteDropped;
    int startWithView;
    UIActionSheet *actionSheet;
    IBOutlet UILabel *sharingLabel;
}
@property(nonatomic)    NSMutableDictionary *vidThumbs;
@property(nonatomic) IBOutlet UITextView *textBox;
@property(nonatomic) IBOutlet UIButton *hideKeyboardButton;
@property(nonatomic) IBOutlet UISegmentedControl *typeControl;
@property(nonatomic) Note *note;
@property(nonatomic, unsafe_unretained) id delegate;
@property(nonatomic)UIActionSheet *actionSheet;
@property(nonatomic)IBOutlet UILabel *sharingLabel;

@property (nonatomic) IBOutlet UITableView *contentTable;
@property(nonatomic)IBOutlet UIButton *cameraButton;
@property(nonatomic)IBOutlet UIButton *audioButton;
@property(nonatomic)IBOutlet UIButton *publicButton;
@property(nonatomic)IBOutlet UIButton *textButton;
@property(nonatomic)IBOutlet UIButton *mapButton;
@property(nonatomic)IBOutlet UIButton *libraryButton;
@property(nonatomic)IBOutlet UITextField *textField;
@property(nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic) IBOutlet UIPageControl *pageControl;
@property(nonatomic) NSMutableArray *viewControllers;
@property(readwrite, assign) BOOL noteValid;
@property(readwrite, assign) BOOL noteChanged;
@property(readwrite, assign) BOOL noteDropped;
@property(readwrite, assign) int startWithView;



- (IBAction)previewButtonTouchAction;
-(IBAction)cameraButtonTouchAction;
-(IBAction)audioButtonTouchAction;
-(IBAction)libraryButtonTouchAction;
-(IBAction)mapButtonTouchAction;
-(IBAction)publicButtonTouchAction;
-(IBAction)textButtonTouchAction;
-(void)refresh;
- (void)updateTable;
//-(IBAction)controlChanged:(id)sender;
- (void)refreshViewFromModel;
-(void)tagButtonTouchAction;
-(void)addCDUploadsToNote;
- (IBAction)backButtonTouchAction: (id) sender;
@end
