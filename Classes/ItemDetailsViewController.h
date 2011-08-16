//
//  ItemDetailsViewController.h
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Item.h"
#import "ARISMoviePlayerViewController.h"
#import "AsyncImageView.h"
#import "itemDetailsMode.h"
#import "TitleAndDecriptionFormViewController.h"


@interface ItemDetailsViewController : UIViewController <UIWebViewDelegate,UITextViewDelegate> {
	Item *item;
	//ARISMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video

	bool inInventory;
	bool descriptionShowing;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *dropButton;
	IBOutlet UIBarButtonItem *deleteButton;
	IBOutlet UIBarButtonItem *pickupButton;
	IBOutlet UIBarButtonItem *detailButton;
    IBOutlet UITextView *textBox;
    IBOutlet UIButton *saveButton;
	IBOutlet UIButton *backButton;
	IBOutlet AsyncImageView *itemImageView;
	IBOutlet UIWebView *itemDescriptionView;
    IBOutlet UIWebView *itemWebView;
	IBOutlet UIScrollView *scrollView;
	UIButton *mediaPlaybackButton;
	ItemDetailsModeType mode;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    BOOL isLink;

}
@property(readwrite, assign) BOOL isLink;

@property(readwrite, retain) Item *item;
@property(readwrite) bool inInventory;
@property(readwrite) ItemDetailsModeType mode;
@property(nonatomic,retain)	IBOutlet AsyncImageView *itemImageView;
@property(nonatomic,retain) IBOutlet UIWebView *itemWebView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain)IBOutlet UIWebView *itemDescriptionView;;
@property(nonatomic,retain) IBOutlet UITextView *textBox;
@property(nonatomic, retain) IBOutlet UIButton *saveButton;

- (IBAction)dropButtonTouchAction: (id) sender;
- (IBAction)deleteButtonTouchAction: (id) sender;
- (IBAction)backButtonTouchAction: (id) sender;
- (IBAction)pickupButtonTouchAction: (id) sender;
- (IBAction)playMovie:(id)sender;
- (IBAction)toggleDescription:(id)sender;
-(void)doActionWithMode: (ItemDetailsModeType) itemMode quantity: (int) quantity;
- (void)updateQuantityDisplay;

- (IBAction)saveButtonTouchAction;
- (void) hideKeyboard;
-(void) editButtonPressed;
- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm;
- (void)displayTitleandDescriptionForm;
- (void) showWaitingIndicator;
- (void) dismissWaitingIndicator;
@end
