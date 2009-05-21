//
//  InventoryBar.h
//  fun with button bars
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyBarItemView.h"
#import "IndicatorView.h"
#import "NearbyObjectProtocol.h"


@interface NearbyBar : UIView {
	float usedSpace;
	float exposedHeight;
	float hiddenHeight;
	UIView *buttonView;
	CGPoint lastTouch;
	float maxScroll;
	BOOL hidden;
	BOOL dragged;
	UIColor *fillColor;
	IndicatorView *indicator;
}
@property(readwrite) 	BOOL hidden;
@property(readwrite)	float exposedHeight;
@property(readwrite)	float hiddenHeight;
@property(readwrite,retain) UIColor *fillColor;
@property(readwrite,retain) IndicatorView *indicator;


- (void)addItem:(NSObject <NearbyObjectProtocol> *)item;
- (void)clearAllItems;
- (void)addItemView:(NearbyBarItemView *)itemView;
- (IBAction)scrollLeft:(id)sender;
- (IBAction)scrollRight:(id)sender;


@end
