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
#import <MediaPlayer/MediaPlayer.h>


@interface ItemDetailsViewController : UIViewController {
	AppModel *appModel;
	Item *item;
	MPMoviePlayerController *mMoviePlayer; //only used if item is a video
	bool inInventory;
	IBOutlet UITextView *descriptionView;
	IBOutlet UIButton *dropButton;
	IBOutlet UIButton *deleteButton;
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *pickupButton;
}

@property(copy, readwrite) AppModel *appModel;
@property(copy, readwrite) Item *item;
@property(readwrite) bool inInventory;
@property (nonatomic, retain) UITextView *descriptionView;
@property (nonatomic, retain) UIButton *dropButton;
@property (nonatomic, retain) UIButton *deleteButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, readwrite, retain) UIButton *pickupButton;

- (void) setModel:(AppModel *)model;
- (void) setItem:(Item *)item;
- (IBAction)dropButtonTouchAction: (id) sender;
- (IBAction)deleteButtonTouchAction: (id) sender;
- (IBAction)backButtonTouchAction: (id) sender;
- (IBAction)pickupButtonTouchAction: (id) sender;
- (IBAction)playMovie:(id)sender;


@end
