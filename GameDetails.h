//
//  GameDetails.h
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"
#import "Media.h"


@interface GameDetails : UIViewController <UITableViewDataSource,UITableViewDelegate,
                                        UITextViewDelegate,  UIWebViewDelegate>{
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
    AsyncImageView *mediaImageView; 
    CGFloat newHeight;
    Media *splashMedia;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIWebView *descriptionWebView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorsLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, assign) CGFloat  newHeight;
@property (nonatomic,retain)AsyncImageView *mediaImageView;
@property (nonatomic, retain)Media *splashMedia;


@end
