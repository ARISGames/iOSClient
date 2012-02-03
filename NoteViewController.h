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
#import "Note.h"
#import <AVFoundation/AVFoundation.h>


@interface NoteViewController : UIViewController <AVAudioSessionDelegate,UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, AVAudioPlayerDelegate,UIActionSheetDelegate>{
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
    id delegate;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    NSMutableDictionary *vidThumbs;
    int pageNumber;
    int numPages;
    AVPlayer *soundPlayer;
    id timeObserver;
    BOOL noteValid, noteChanged, noteDropped;
    int startWithView;
    UIActionSheet *actionSheet;
    IBOutlet UILabel *sharingLabel;
}
@property(nonatomic,retain)    NSMutableDictionary *vidThumbs;
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *hideKeyboardButton;
@property(nonatomic,retain) IBOutlet UISegmentedControl *typeControl;
@property(nonatomic,retain) Note *note;
@property(nonatomic,retain) id delegate;
@property(nonatomic,retain)UIActionSheet *actionSheet;
@property(nonatomic,retain)IBOutlet UILabel *sharingLabel;

@property (nonatomic, retain) IBOutlet UITableView *contentTable;
@property(nonatomic,retain)IBOutlet UIButton *cameraButton;
@property(nonatomic,retain)IBOutlet UIButton *audioButton;
@property(nonatomic,retain)IBOutlet UIButton *publicButton;
@property(nonatomic,retain)IBOutlet UIButton *textButton;
@property(nonatomic,retain)IBOutlet UIButton *mapButton;
@property(nonatomic,retain)IBOutlet UIButton *libraryButton;
@property(nonatomic,retain)IBOutlet UITextField *textField;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property(nonatomic, retain) NSMutableArray *viewControllers;
@property(readwrite, retain) AVPlayer *soundPlayer;
@property(readwrite, assign) BOOL noteValid;
@property(readwrite, assign) BOOL noteChanged;
@property(readwrite, assign) BOOL noteDropped;
@property(readwrite, assign) int startWithView;



- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm;
- (void)displayTitleandDescriptionForm;
-(IBAction)hideKeyboardTouchAction;
- (IBAction)previewButtonTouchAction;
- (void)loadNewPageWithView:(NSString *)view;
-(IBAction)cameraButtonTouchAction;
-(IBAction)audioButtonTouchAction;
-(IBAction)libraryButtonTouchAction;
-(IBAction)mapButtonTouchAction;
-(IBAction)publicButtonTouchAction;
-(IBAction)textButtonTouchAction;
-(void)refresh;
-(void)showLoadingIndicator;
- (void)updateTable;
//-(IBAction)controlChanged:(id)sender;
- (void)refreshViewFromModel;
-(void)tagButtonTouchAction;
-(void)movieThumbDidFinish:(NSNotification*) aNotification;

@end
