//
//  NearbyBar.m
//  Displayes a view to show nearby objects
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyBarItemView.h"
#import "NearbyObjectProtocol.h"


@interface NearbyBar : UIView {
	float usedSpace;
	UIView *buttonView;
	CGPoint lastTouch;
	float maxScroll;
	BOOL dragged;
	BOOL inactive;
	BOOL itemTouch;
	UIColor *fillColor;
}
@property(readwrite)	BOOL inactive;
@property(readwrite,retain) UIColor *fillColor;


- (void)addItem:(NSObject <NearbyObjectProtocol> *)item;
- (void)clearAllItems;
- (void)addItemView:(NearbyBarItemView *)itemView;



@end
