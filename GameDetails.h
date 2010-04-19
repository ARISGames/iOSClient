//
//  GameDetails.h
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import <MapKit/MapKit.h>


@interface GameDetails : UIViewController <MKMapViewDelegate, UITextViewDelegate>{
	Game *game; 
	IBOutlet MKMapView *map;
	IBOutlet UIWebView *descriptionWebView;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UIWebView *descriptionWebView;


@end
