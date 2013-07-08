//
//  WaveSampleProviderDelegate.h
//  CoreAudioTest
//
//  Created by Gyetván András on 6/26/12.
//  Copyright (c) 2012 DroidZONE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WaveSampleProvider;

@protocol WaveSampleProviderDelegate <NSObject>

- (void) sampleProcessed:(WaveSampleProvider *)provider;
- (void) statusUpdated:(WaveSampleProvider *)provider;
-(void)setAudioLength:(float)seconds;

@end
