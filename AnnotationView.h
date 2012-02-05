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
#define IMAGE_HEIGHT 30


@interface AnnotationView : MKAnnotationView {
	CGRect titleRect;
	CGRect subtitleRect;
	CGRect contentRect;
	UIFont *titleFont;
	UIFont *subtitleFont;
	NSMutableData *asyncData;
	UIImage *icon;
	AsyncMediaImageView *iconView;
}

@property (readwrite) CGRect titleRect;
@property (readwrite) CGRect subtitleRect;
@property (readwrite) CGRect contentRect;
@property (readwrite, retain) UIFont *titleFont;
@property (readwrite, retain) UIFont *subtitleFont;
@property (readwrite, retain) UIImage *icon;

//- (void)setImageFromURL:(NSString *)imageURLString;

@end
