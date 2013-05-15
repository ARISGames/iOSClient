//
//  GameDetailsViewController.h
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "AsyncMediaImageView.h"
#import "Media.h"

@protocol GameDetailsViewControllerDelegate

- (void) gameDetailsWereConfirmed:(Game *)g;
- (void) gameDetailsWereCanceled:(Game *)g;

@end

@interface GameDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,  UIWebViewDelegate>
{
	Game *game; 
    IBOutlet UITableView *tableView;
    IBOutlet UIWebView *descriptionWebView;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UILabel *authorsLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIView *contentView;
    IBOutlet UISegmentedControl *segmentedControl;
    AsyncMediaImageView *mediaImageView; 
    CGFloat newHeight;
    NSIndexPath *descriptionIndexPath;
}

@property (nonatomic) NSIndexPath *descriptionIndexPath;
@property (nonatomic) Game *game;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIWebView *descriptionWebView;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UILabel *authorsLabel;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, assign) CGFloat  newHeight;
@property (nonatomic) AsyncMediaImageView *mediaImageView;

- (id) initWithGame:(Game *)g delegate:(id<GameDetailsViewControllerDelegate>)d;

@end
