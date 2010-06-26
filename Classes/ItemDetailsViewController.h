//
//  ItemDetailsViewController.h
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";
#import "Item.h";
#import "ARISMoviePlayerViewController.h"
#import "AsyncImageView.h"


@interface ItemDetailsViewController : UIViewController {
	AppModel *appModel;
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
	IBOutlet UIButton *backButton;

	
	IBOutlet AsyncImageView *itemImageView;
	IBOutlet UIWebView *itemDescriptionView;
	
	IBOutlet UIScrollView *scrollView;
}

@property(readwrite, retain) AppModel *appModel;
@property(readwrite, retain) Item *item;
@property(readwrite) bool inInventory;


- (IBAction)dropButtonTouchAction: (id) sender;
- (IBAction)deleteButtonTouchAction: (id) sender;
- (IBAction)backButtonTouchAction: (id) sender;
- (IBAction)pickupButtonTouchAction: (id) sender;
- (IBAction)playMovie:(id)sender;
- (IBAction)toggleDescription:(id)sender;

@end
