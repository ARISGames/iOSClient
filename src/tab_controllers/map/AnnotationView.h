//
//  AnnotationView.h
//  ARIS
//
//  Created by Brian Deith on 8/11/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "AsyncMediaImageView.h"

#define POINTER_LENGTH 10
#define WIGGLE_DISTANCE 3.0
#define WIGGLE_SPEED 0.3
#define WIGGLE_FRAMELENGTH 0.05 //<-The lower = the faster
#define ANNOTATION_MAX_WIDTH 300
#define ANNOTATION_PADDING 5.0
#define IMAGE_HEIGHT 30
#define IMAGE_WIDTH 30


@interface AnnotationView : MKAnnotationView
{
	CGRect titleRect;
	CGRect subtitleRect;
	CGRect contentRect;
	UIFont *titleFont;
	UIFont *subtitleFont;
	NSMutableData *asyncData;
	UIImage *icon;
	AsyncMediaImageView *iconView;
    bool showTitle;
    bool shouldWiggle;
    float totalWiggleOffsetFromOriginalPosition;
    float incrementalWiggleOffset;
    float xOnSinWave;
}

@property (readwrite) CGRect titleRect;
@property (readwrite) CGRect subtitleRect;
@property (readwrite) CGRect contentRect;
@property (readwrite) UIFont *titleFont;
@property (readwrite) UIFont *subtitleFont;
@property (readwrite) UIImage *icon;
@property (readwrite) AsyncMediaImageView *iconView;
@property (readwrite) bool showTitle;
@property (readwrite) bool shouldWiggle;
@property (readwrite) float totalWiggleOffsetFromOriginalPosition;
@property (readwrite) float incrementalWiggleOffset;
@property (readwrite) float xOnSinWave;

@end
