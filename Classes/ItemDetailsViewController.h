//
//  ItemDetailsViewController.h
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h";
#import "Item.h";
#import "ARISMoviePlayerViewController.h"
#import "AsyncImageView.h"

typedef enum {
	kItemDetailsViewing,
	kItemDetailsDropping,
	kItemDetailsDestroying,
	kItemDetailsPickingUp
} ItemDetailsModeType;


@interface ItemDetailsViewController : UIViewController  {
	Item *item;
	//ARISMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video

	bool inInventory;
	bool descriptionShowing;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *dropButton;
	IBOutlet UIBarButtonItem *deleteButton;
	IBOutlet UIBarButtonItem *pickupButton;
    IBOutlet UIBarButtonItem *dropOneButton;
	IBOutlet UIBarButtonItem *deleteOneButton;
	IBOutlet UIBarButtonItem *pickupOneButton;
    IBOutlet UIBarButtonItem *dropAllButton;
	IBOutlet UIBarButtonItem *deleteAllButton;
	IBOutlet UIBarButtonItem *pickupAllButton;
	IBOutlet UIBarButtonItem *detailButton;
    
	IBOutlet UIButton *backButton;
	IBOutlet AsyncImageView *itemImageView;
	IBOutlet UIWebView *itemDescriptionView;
	IBOutlet UIScrollView *scrollView;
	UIButton *mediaPlaybackButton;
	ItemDetailsModeType mode;

}

@property(readwrite, retain) Item *item;
@property(readwrite) bool inInventory;
@property(readwrite) ItemDetailsModeType mode;
@property(nonatomic,retain)	IBOutlet AsyncImageView *itemImageView;


- (IBAction)dropButtonTouchAction: (id) sender;
- (IBAction)deleteButtonTouchAction: (id) sender;
- (IBAction)backButtonTouchAction: (id) sender;
- (IBAction)pickupButtonTouchAction: (id) sender;
- (IBAction)leftButtonTouchAction: (id) sender;
- (IBAction)rightButtonTouchAction: (id) sender;
- (IBAction)playMovie:(id)sender;
- (IBAction)toggleDescription:(id)sender;
-(void)doActionWithMode: (ItemDetailsModeType) itemMode quantity: (int) quantity;
- (void)updateQuantityDisplay;


@end
