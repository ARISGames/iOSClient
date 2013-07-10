//
//  WaveformControl.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaveformControl;

@protocol WaveformControlDelegate <NSObject>

-(CGPoint *)getSampleData;
-(int)getSampleLength;

@end

@interface WaveformControl : UIControl

@property (assign) id<WaveformControlDelegate> delegate;

@end
