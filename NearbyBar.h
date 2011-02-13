//
//  NearbyBar.h
//  Displayes a view to show nearby objects
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyBarItemView.h"
#import "NearbyObjectProtocol.h"

#define kNearbyBarExposedHeight 40


@interface NearbyBar : UIView {
	NSMutableArray *oldNearbyLocationList;
	float usedSpace;
	UIView *buttonView;
	CGPoint lastTouch;
	float maxScroll;
	BOOL dragged;
	BOOL itemTouch;
	UIColor *fillColor;
}

@property(readwrite,retain) UIColor *fillColor;
@property(nonatomic,retain) NSMutableArray *oldNearbyLocationList;


- (void)refreshViewFromModel;
- (void)addItem:(NSObject <NearbyObjectProtocol> *)item;
- (void)clearAllItems;
- (void)addItemView:(NearbyBarItemView *)itemView;



@end
