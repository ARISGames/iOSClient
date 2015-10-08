//
//  WaveSampleProvider.h
//  CoreAudioTest
//
//  Created by Gyetván András on 6/22/12.
//  Copyright (c) 2012 DroidZONE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

@class WaveSampleProvider;

@protocol WaveSampleProviderDelegate <NSObject>
- (void) sampleProcessed:(WaveSampleProvider *)provider;
- (void) setAudioLength:(float)seconds;
@end

typedef enum {
  LOADING,
  LOADED,
  ERROR
} WaveSampleStatus;

@interface WaveSampleProvider : NSObject
{
  ExtAudioFileRef extAFRef;
  Float64 extAFRateRatio;
  long extAFNumChannels;
  BOOL extAFReachedEOF;
  NSString *_path;
  WaveSampleStatus status;
  NSString *statusMessage;
  NSMutableArray *sampleData;
  NSMutableArray *normalizedData;
  long binSize;
  //long lengthInSec;
  long minute;
  long sec;
  NSURL *audioURL;
  NSString *title;
    float **maximumAudioSamples;
}

@property (readonly, nonatomic) WaveSampleStatus status;
@property (readonly, nonatomic) NSString *statusMessage;
@property (readonly, nonatomic) NSURL *audioURL;
@property (assign, nonatomic) long binSize;
@property (assign, nonatomic) long minute;
@property (assign, nonatomic) long sec;
@property (readonly) NSString *title;

- (id) initWithURL:(NSURL *)u delegate:(id<WaveSampleProviderDelegate>)d;
- (void) createSampleData;
- (float *)dataForResolution:(long)pixelWide lenght:(long *)length;

@end
