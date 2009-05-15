//
//  InventoryBar.h
//  fun with button bars
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InventoryBarItemView.h"
#import "NearbyObjectProtocol.h"


@interface InventoryBar : UIView {
	float usedSpace;
	UIView *buttonView;
	CGPoint lastTouch;
	float maxScroll;
	BOOL hidden;
	BOOL dragged;

}
@property(readwrite) 	BOOL hidden;

- (void)addItem:(NSObject <NearbyObjectProtocol> *)item;
- (void)clearAllItems;
- (void)addItemView:(InventoryBarItemView *)itemView;
- (IBAction)scrollLeft:(id)sender;
- (IBAction)scrollRight:(id)sender;


@end
