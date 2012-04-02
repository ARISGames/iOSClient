//
//  AudioMeter.h
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AudioMeter : UIView {

	NSMutableArray *barViews;
	int numberofBars;
	int spacingBetweenBars;
	UIColor *activeColor;
	UIColor *inactiveColor;
}

@property(readwrite) NSMutableArray *barViews;
@property(readwrite) int numberofBars;
@property(readwrite) int spacingBetweenBars;
@property(readwrite) UIColor *activeColor;
@property(readwrite) UIColor *inactiveColor;


- (void)updateLevel:(double)level;

@end
