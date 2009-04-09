//
//  RMMarker.h
//  MapView
//
//  Created by Joseph Gentle on 13/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapLayer.h"
#import "RMFoundation.h"

@class RMMarkerStyle;

extern NSString * const RMMarkerBlueKey;
extern NSString * const RMMarkerRedKey;

@interface RMMarker : RMMapLayer <RMMovingMapLayer> {
	RMXYPoint location;	
	NSObject* data;
	
	// A label which comes up when you tap the marker
	UIView* labelView;
}

+ (RMMarker*) markerWithNamedStyle: (NSString*) styleName;
+ (CGImageRef) markerImage: (NSString *) key;
+ (CGImageRef) loadPNGFromBundle: (NSString *)filename;

- (id) initWithCGImage: (CGImageRef) image anchorPoint: (CGPoint) anchorPoint;
- (id) initWithCGImage: (CGImageRef) image;
- (id) initWithKey: (NSString*) key;
- (id) initWithUIImage: (UIImage*) image;
- (id) initWithStyle: (RMMarkerStyle*) style;
- (id) initWithNamedStyle: (NSString*) styleName;

- (void) setLabel: (UIView*)aView;
- (void) setTextLabel: (NSString*)text;
- (void) setTextLabel: (NSString*)text toPosition:(CGPoint)position;
- (void) toggleLabel;
- (void) showLabel;
- (void) hideLabel;
- (void) removeLabel;

- (void) replaceImage:(CGImageRef)image anchorPoint:(CGPoint)_anchorPoint;
- (void) hide;
- (void) unhide;

- (void) dealloc;

@property (assign, nonatomic) RMXYPoint location;
@property (retain) NSObject* data;
@property (nonatomic, retain) UIView* labelView;

// Call this with either RMMarkerBlue or RMMarkerRed for the key.
+ (CGImageRef) markerImage: (NSString *) key;

@end
