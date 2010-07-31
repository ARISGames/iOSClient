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


@interface GameDetails : UIViewController <MKMapViewDelegate, UITextViewDelegate, MKReverseGeocoderDelegate, UIWebViewDelegate>{
	Game *game; 
	IBOutlet MKMapView *map;
	IBOutlet UILabel *mapLabel;
	IBOutlet UIWebView *descriptionWebView;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UILabel *playersLabel;
	IBOutlet UILabel *authorsLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet AsyncImageView *iconView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIView *contentView;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UILabel *mapLabel;
@property (nonatomic, retain) IBOutlet UIWebView *descriptionWebView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *playersLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorsLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet AsyncImageView *iconView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *contentView;


@end
