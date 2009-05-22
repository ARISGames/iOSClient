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
	float shrunkenHeight;
	UIView *buttonView;
	CGPoint lastTouch;
	float maxScroll;
	BOOL shrunken;
	BOOL dragged;
	BOOL inactive;
	BOOL itemTouch;
	UIColor *fillColor;
	IndicatorView *indicator;
}
@property(readwrite) 	BOOL shrunken;
@property(readwrite)	BOOL inactive;
@property(readwrite)	float exposedHeight;
@property(readwrite)	float shrunkenHeight;
@property(readwrite,retain) UIColor *fillColor;
@property(readwrite,retain) IndicatorView *indicator;


- (void)addItem:(NSObject <NearbyObjectProtocol> *)item;
- (void)clearAllItems;
- (void)addItemView:(NearbyBarItemView *)itemView;
- (IBAction)scrollLeft:(id)sender;
- (IBAction)scrollRight:(id)sender;


@end
