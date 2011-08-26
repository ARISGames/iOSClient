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


@interface NoteViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>{
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
    int pageNumber;
    int numPages;

}
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *hideKeyboardButton;
@property(nonatomic,retain) IBOutlet UISegmentedControl *typeControl;
@property(nonatomic,retain) Note *note;
@property(nonatomic,retain) id delegate;
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
- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm;
- (void)displayTitleandDescriptionForm;
-(IBAction)hideKeyboardTouchAction;
- (IBAction)saveButtonTouchAction;
- (void)loadNewPageWithView:(NSString *)view;
-(IBAction)cameraButtonTouchAction;
-(IBAction)audioButtonTouchAction;
-(IBAction)libraryButtonTouchAction;
-(IBAction)mapButtonTouchAction;
-(IBAction)publicButtonTouchAction;
-(IBAction)textButtonTouchAction;
-(void)refresh;
-(void)showLoadingIndicator;
//-(IBAction)controlChanged:(id)sender;
- (void)refreshViewFromModel;
@end
