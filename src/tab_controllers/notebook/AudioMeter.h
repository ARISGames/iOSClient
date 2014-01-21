//
//  AudioMeter.h
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioMeter;
@protocol AudioMeterDelegate
- (double) meterRequestsLevel:(AudioMeter *)m;
@end

@interface AudioMeter : UIView
- (id) initWithDelegate:(id<AudioMeterDelegate>)d;
- (void) startRequestingLevels;
- (void) stopRequestingLevels;
- (void) setLevel:(double)l;
- (double) level;
@end
