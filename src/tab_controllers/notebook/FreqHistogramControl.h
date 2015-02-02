//
//  FreqHistogramControl.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FreqHistogramControl;

@protocol FreqHistogramControlDelegate <NSObject>
- (void) freqHistogramControl:(FreqHistogramControl *)waveform wasTouched:(NSSet *)touches;
@end

@interface FreqHistogramControl : UIControl

- (id) initWithFrame:(CGRect)f delegate:(id<FreqHistogramControlDelegate>)d;

@property float *fourierData;
@property float largestMag;
@property float currentFreqX;

@end
