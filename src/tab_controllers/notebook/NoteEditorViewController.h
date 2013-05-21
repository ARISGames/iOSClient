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


@interface NoteEditorViewController : UIViewController <AVAudioSessionDelegate,UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, AVAudioPlayerDelegate,UIActionSheetDelegate>
{
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

@property (nonatomic, strong) NSMutableDictionary *vidThumbs;
@property (nonatomic, strong) IBOutlet UITextView *textBox;
@property (nonatomic, strong) IBOutlet UIButton *hideKeyboardButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl *typeControl;
@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) IBOutlet UILabel *sharingLabel;

@property (nonatomic, strong) IBOutlet UITableView *contentTable;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (nonatomic, strong) IBOutlet UIButton *audioButton;
@property (nonatomic, strong) IBOutlet UIButton *publicButton;
@property (nonatomic, strong) IBOutlet UIButton *textButton;
@property (nonatomic, strong) IBOutlet UIButton *mapButton;
@property (nonatomic, strong) IBOutlet UIButton *libraryButton;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (readwrite, assign) BOOL noteValid;
@property (readwrite, assign) BOOL noteChanged;
@property (readwrite, assign) BOOL noteDropped;
@property (readwrite, assign) int startWithView;

@property (nonatomic, unsafe_unretained) id delegate;

- (IBAction) previewButtonTouchAction;
- (IBAction) cameraButtonTouchAction;
- (IBAction) audioButtonTouchAction;
- (IBAction) libraryButtonTouchAction;
- (IBAction) mapButtonTouchAction;
- (IBAction) publicButtonTouchAction;
- (IBAction) textButtonTouchAction;
- (void) updateTable;
- (void) refreshViewFromModel;
- (void) tagButtonTouchAction;
- (void) addCDUploadsToNote;

@end
