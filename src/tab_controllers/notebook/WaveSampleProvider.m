//
//  WaveSampleProvider.m
//  CoreAudioTest
//
//  Created by Gyetván András on 6/22/12.
//  Copyright (c) 2012 DroidZONE. All rights reserved.
//

#import "WaveSampleProvider.h"
#import <Accelerate/Accelerate.h>

@interface WaveSampleProvider ()
{
    id<WaveSampleProviderDelegate> __unsafe_unretained delegate;; 
}
@end

@implementation WaveSampleProvider
@synthesize status, statusMessage, binSize, minute, sec, audioURL;

- (id) initWithURL:(NSURL *)u delegate:(id<WaveSampleProviderDelegate>)d
{
	if(self = [super init])
    {
        delegate = d;
		extAFNumChannels = 2;
		binSize = 50;
		audioURL = u;
		title = [[u lastPathComponent] copy];
        [self status:LOADING message:@"Processing"]; 
	}
	return self;
}

- (NSString *)title
{
	return title;	
}

- (void) status:(WaveSampleStatus)theStatus message:(NSString *)desc;
{
	status = theStatus;
	statusMessage = [desc copy];
}

- (void) createSampleData
{
	sampleData = [NSMutableArray array];
	[self performSelectorInBackground:@selector(loadSample) withObject:nil];
}

- (void) informDelegateOfFinish
{
	if(delegate != nil && [delegate respondsToSelector:@selector(sampleProcessed:)]) 
        [delegate sampleProcessed:self];
}

- (void) loadSample
{
	[self processSample];	
	[self performSelectorOnMainThread:@selector(informDelegateOfFinish) withObject:nil waitUntilDone:NO];
}

- (void) processSample
{
	extAFReachedEOF = NO;
	OSStatus err;
	CFURLRef inpUrl = (__bridge CFURLRef)audioURL;
	err = ExtAudioFileOpenURL(inpUrl, &extAFRef);
	if(err != noErr)
    {
		[self status:ERROR message:@"Cannot open audio file"];
		return;
	}
	
	AudioFileID afid;
	AudioFileOpenURL(inpUrl, kAudioFileReadPermission, 0, &afid);
	UInt32 size = 0;
	UInt32 writable;
	OSStatus error = AudioFileGetPropertyInfo(afid, kAudioFilePropertyInfoDictionary, &size, &writable);
	if(error == noErr)
    {
		CFDictionaryRef info = NULL;
		error = AudioFileGetProperty(afid, kAudioFilePropertyInfoDictionary, &size, &info);
	}
	AudioFileClose(afid);
	
	AudioStreamBasicDescription fileFormat;
	
    UInt32 propSize = sizeof(fileFormat);
    memset(&fileFormat, 0, sizeof(AudioStreamBasicDescription));
	
    err = ExtAudioFileGetProperty(extAFRef, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
	if(err != noErr)
    {
		[self status:ERROR message:@"Cannot get audio file properties"];
		return;
	}
	
	Float64 sampleRate = 44100.0;
    extAFRateRatio = sampleRate / fileFormat.mSampleRate;
	
    AudioStreamBasicDescription clientFormat;
    propSize = sizeof(clientFormat);
	
    memset(&clientFormat, 0, sizeof(AudioStreamBasicDescription));
    clientFormat.mFormatID           = kAudioFormatLinearPCM;
    clientFormat.mSampleRate         = sampleRate;
    clientFormat.mFormatFlags        = kAudioFormatFlagIsFloat;//kAudioFormatFlagsCanonical;//kAudioFormatFlagIsFloat | kAudioFormatFlagIsAlignedHigh | kAudioFormatFlagsCanonical;// | kAudioFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;// |  kAudioFormatFlagIsNonInterleaved;
    clientFormat.mChannelsPerFrame   = (unsigned int)extAFNumChannels;
    clientFormat.mBitsPerChannel     = sizeof(float) * 8;
    clientFormat.mFramesPerPacket    = 1;
    clientFormat.mBytesPerFrame      = (unsigned int)extAFNumChannels * sizeof(float);
    clientFormat.mBytesPerPacket     = (unsigned int)extAFNumChannels * sizeof(float);
//    clientFormat.mReserved           = 0;
	
    err = ExtAudioFileSetProperty(extAFRef, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
	if(err != noErr)
    {
		[self status:ERROR message:@"Cannot convert audio file to PCM format"];
		return;
	}

	SInt64 NUM_FRAMES_PER_READ = 500*binSize;
    float *audio[extAFNumChannels];
	
    for(long i=0; i < extAFNumChannels; i++)
        audio[i] = (float *)malloc(sizeof(float)*NUM_FRAMES_PER_READ);
	long packetReads = 0;
    
    long i = 0;
	while(!extAFReachedEOF)
    {
		long k = 0;
        if((k = [self readConsecutive:NUM_FRAMES_PER_READ intoArray:audio]) < 0)
        { 
			[self status:ERROR message:@"Cannot read audio file"];
			return;
        }
		[self calculateSampleFromArray:audio lenght:k];
        
		packetReads += k;
        i++;
	}
    
	float allSec = packetReads / 44100;
    [delegate setAudioLength:allSec];
	minute = allSec / 60;
	sec = ceil(allSec - ((float)(minute * 60) + 0.5));
	err = ExtAudioFileDispose(extAFRef);
	if(err != noErr)
    {
		[self status:ERROR message:@"Error closing audio file"];
		return;
	}
    for(long i=0; i < extAFNumChannels; i++) free(audio[i]);
	
	[self normalizeSample];
	[self status:LOADED message:@"Sample data loaded"];
}

- (void) normalizeSample
{
	normalizedData = [NSMutableArray array];
	float min = MAXFLOAT;
	float max = -MAXFLOAT;
	for(NSNumber *num in sampleData)
    {
		float val = num.floatValue;
		if(val < min) min = val;
		if(val > max) max = val;
	}
	for(NSNumber *num in sampleData)
    {
		float val = num.floatValue;
		if(val > 1.0) val = 1.0;
		if(val < 0.0) val = 0.0;
		NSNumber *nval = [NSNumber numberWithFloat:val];
		[normalizedData addObject:nval];
	}	
	sampleData = nil;
}

- (void) calculateSampleFromArray:(float**)audio lenght:(long)length
{
	float maxValues[extAFNumChannels];
	for(long i = 0; i < extAFNumChannels;i++)
		maxValues[i] = 0.0;
	for(long v = 0; v < length; v+=binSize)
    {
		for(long c = 0; c < extAFNumChannels;c++)
        {
			for(long p = 0;p < binSize;p++)
            {
				long idx = v + p;
				if(idx < length)
                {
					float val = audio[c][idx];
					if(val > maxValues[c]) maxValues[c] = val;
				}
                else break;
			}
		}
		float maxValue = 0;
		for(long i = 0; i < extAFNumChannels;i++) {
			if(maxValues[i] > maxValue) maxValue = maxValues[i]; 
		}
		NSNumber *nMaxValue = [NSNumber numberWithFloat:maxValue];
		[sampleData addObject:nMaxValue];
	}
}

- (OSStatus) readConsecutive:(SInt64)numFrames intoArray:(float**)audio
{
    OSStatus err = noErr;
	
    if(!extAFRef) return -1;
	
    long kSegmentSize;
    if (extAFRateRatio < 1.) kSegmentSize = (long)(numFrames * extAFNumChannels / extAFRateRatio + .5);
    else                     kSegmentSize = (long)(numFrames * extAFNumChannels * extAFRateRatio + .5);
	
    UInt32 loadedPackets;
    
    float *data = (float*)malloc(kSegmentSize*sizeof(float));
    if(!data) return -1;
    
    UInt32 numPackets = (unsigned int)numFrames; // Frames to read
    UInt32 samples = numPackets * (unsigned int)extAFNumChannels; // 2 channels (samples) per frame
    
    AudioBufferList bufList;
    bufList.mNumberBuffers = 1;
    bufList.mBuffers[0].mNumberChannels = (unsigned int)extAFNumChannels; // Always 2 channels in this example
    bufList.mBuffers[0].mData = data; // data is a pointer (float*) to our sample buffer
    bufList.mBuffers[0].mDataByteSize = samples * sizeof(float);
    
    loadedPackets = numPackets;
    
    err = ExtAudioFileRead(extAFRef, &loadedPackets, &bufList);
    if(!err)
    {
        if(audio)
        {
            for(long c = 0; c < extAFNumChannels; c++)
            {
                if(!audio[c]) continue;
                for(long v = 0; v < numFrames; v++)
                {
                    if(v < loadedPackets) audio[c][v] = data[v*extAFNumChannels+c];
                    else                  audio[c][v] = 0.;
                }
            }
        }
    }
    free(data);
    if (err != noErr) return err;
    if (loadedPackets < numFrames) extAFReachedEOF = YES;
    return loadedPackets;
}	

- (float *)dataForResolution:(long)pixelWide lenght:(long *)length
{
	long rangeLength = normalizedData.count / pixelWide + 1;
	long retLength = pixelWide;
	float *ret = (float *)calloc(sizeof(float),retLength);
	long k = 0;
	for(long r = 0; r < normalizedData.count; r += rangeLength)
    {
		float valMax = 0;
		for(long j = 0; j < rangeLength; j++)
        {
			long idx = r + j;
			if(idx < normalizedData.count)
            {
				NSNumber *nVal = [normalizedData objectAtIndex:idx];
				float val = nVal.floatValue;
				if(valMax < val) valMax = val;
			}
		}
		ret[k] = valMax;
		k++;
	}
	*length = k;
	return ret;
}

@end
