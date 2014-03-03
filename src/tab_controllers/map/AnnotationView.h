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
#import "ARISMediaView.h"

#define POINTER_LENGTH 10.0f
#define POINTER_WIDTH 10.0f
#define WIGGLE_DISTANCE 3.0
#define WIGGLE_SPEED 0.3
#define WIGGLE_FRAMELENGTH 0.05 //<-The lower = the faster
#define ANNOTATION_MAX_WIDTH 300
#define ANNOTATION_PADDING 5.0
#define IMAGE_HEIGHT 30
#define IMAGE_WIDTH 30

@interface AnnotationView : MKAnnotationView


@end
