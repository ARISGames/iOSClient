//
//  AudioMeter.m
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "AudioMeter.h"


@implementation AudioMeter

@synthesize barViews;
@synthesize numberofBars;
@synthesize spacingBetweenBars;
@synthesize activeColor;
@synthesize inactiveColor;



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
		self.backgroundColor = [UIColor clearColor];
		self.numberofBars = 30;
		self.spacingBetweenBars = 2;
		self.activeColor = [UIColor lightTextColor];
		self.inactiveColor = [UIColor clearColor];
		
		
		//Create a view for each bar
		int width = frame.size.width;
		int height = frame.size.height;
		float totalSpacing = self.spacingBetweenBars * self.numberofBars;
		float remainingHeight = height - totalSpacing;
		float heightPerBar = remainingHeight / self.numberofBars;
		
		self.barViews = [NSMutableArray arrayWithCapacity:self.numberofBars];
		
		for (int i = 0; i<self.numberofBars; i++) {
			int currentPosition = i * (heightPerBar + self.spacingBetweenBars);
			UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, currentPosition, width, heightPerBar)];
			bar.backgroundColor = inactiveColor;
			[self.barViews insertObject:bar atIndex:0];
			[self addSubview:bar];
		}
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateLevel:(double)level {
	int numberToMakeActive = abs(round(self.numberofBars * level));

	for (int i = 0; i<[self.barViews count]; i++) {
		UIView *bar = [self.barViews objectAtIndex:i];
		if (i<numberToMakeActive) {
			bar.backgroundColor = self.activeColor;
		}
		else {
			bar.backgroundColor = self.inactiveColor;
		}
			
	}
	
	[self setNeedsDisplay]; 

}




@end
