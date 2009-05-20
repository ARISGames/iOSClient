//
//  InventoryBarItemView.h
//  fun with button bars
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyObjectProtocol.h"


@interface NearbyBarItemView : UIView {
	NSObject <NearbyObjectProtocol> *nearbyObject;
	NSString *title;
	CGFloat fontSize;
	CGSize textSize;
	UIImage *placardImage;
}
@property(readwrite, retain) NSObject <NearbyObjectProtocol> *nearbyObject;
@property(readwrite,copy) NSString *title;
@property (nonatomic, retain) UIImage *placardImage;


@end
