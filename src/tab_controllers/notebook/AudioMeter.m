//
//  AudioMeter.m
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "AudioMeter.h"

@interface AudioMeter()
{
  NSMutableArray *barViews;
  long numberofBars;
  long spacingBetweenBars;
    double updateInterval;
  UIColor *activeColor;
  UIColor *inactiveColor;
    NSTimer *updateTimer;
    double level;
    id<AudioMeterDelegate> __unsafe_unretained delegate;
}

@end

@implementation AudioMeter

- (id) initWithDelegate:(id<AudioMeterDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
    self.backgroundColor = [UIColor clearColor];
    numberofBars = 30;
    spacingBetweenBars = 2;
        updateInterval = 0.1;
    activeColor = [UIColor blackColor];
    inactiveColor = [UIColor clearColor];
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];

    for(long i = 0; self.subviews.count > 0; i++) [[self.subviews objectAtIndex:0] removeFromSuperview];

    barViews = [NSMutableArray arrayWithCapacity:numberofBars];
    float heightPerBar = (frame.size.height - (spacingBetweenBars * numberofBars)) / numberofBars;
    for(long i = 0; i<numberofBars; i++)
    {
        long currentPosition = (self.frame.size.height - ((i+1) * (heightPerBar + spacingBetweenBars)));
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, currentPosition, frame.size.width, heightPerBar)];
        bar.backgroundColor = inactiveColor;
        [barViews addObject:bar];
        [self addSubview:bar];
    }
}

- (double) level
{
    return level;
}

- (void) setLevel:(double)l
{
    level = l;
  long numberToMakeActive = abs((int)round(numberofBars * level));

  for(long i = 0; i<barViews.count; i++)
    {
    UIView *bar = [barViews objectAtIndex:i];
    if(i < numberToMakeActive) bar.backgroundColor = activeColor;
    else                       bar.backgroundColor = inactiveColor;
  }
}

- (void) startRequestingLevels
{
     updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(requestLevelFromDelegate) userInfo:nil repeats:YES];
}

- (void) stopRequestingLevels
{
    [updateTimer invalidate];
    updateTimer = nil;
}

- (void) requestLevelFromDelegate
{
    [self setLevel:[delegate meterRequestsLevel:self]];
}

- (void) dealloc
{
    [updateTimer invalidate];
}

@end
