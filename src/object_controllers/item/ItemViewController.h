//
//  ItemViewController.h
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"
#import "Item.h"
#import "ARISMoviePlayerViewController.h"
#import "AsyncMediaImageView.h"

typedef enum {
	kItemDetailsViewing,
	kItemDetailsDropping,
	kItemDetailsDestroying,
	kItemDetailsPickingUp
} ItemDetailsModeType;

@interface ItemViewController : GameObjectViewController <UIWebViewDelegate, UITextViewDelegate>
{
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
	IBOutlet AsyncMediaImageView *itemImageView;
	IBOutlet UIWebView *itemDescriptionView;
    IBOutlet UIWebView *itemWebView;
	IBOutlet UIScrollView *scrollView;
	UIButton *mediaPlaybackButton;
	ItemDetailsModeType mode;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property(readwrite) Item *item;
@property(readwrite) bool inInventory;
@property(readwrite) ItemDetailsModeType mode;
@property(nonatomic) IBOutlet AsyncMediaImageView *itemImageView;
@property(nonatomic) IBOutlet UIWebView *itemWebView;
@property(nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic) IBOutlet UIWebView *itemDescriptionView;;
@property(nonatomic) IBOutlet UITextView *textBox;
@property(nonatomic) UIScrollView *scrollView;
@property(nonatomic) IBOutlet UIButton *saveButton;

- (id) initWithItem:(Item *)i delegate:(NSObject<GameObjectViewControllerDelegate> *)d source:(id)s;
- (IBAction)dropButtonTouchAction:(id)sender;
- (IBAction)deleteButtonTouchAction:(id)sender;
- (IBAction)backButtonTouchAction:(id)sender;
- (IBAction)pickupButtonTouchAction:(id)sender;
- (IBAction)playMovie:(id)sender;
- (IBAction)toggleDescription:(id)sender;
- (void)doActionWithMode:(ItemDetailsModeType)itemMode quantity:(int)quantity;
- (void)updateQuantityDisplay;

- (void) showWaitingIndicator;
- (void) dismissWaitingIndicator;
@end
