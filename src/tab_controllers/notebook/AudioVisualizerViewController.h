//
//  AudioVisualizerViewController.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/25/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol AudioVisualizerViewControllerDelegate
- (void) fileWasTrimmed;
@end

@interface AudioVisualizerViewController : ARISViewController 
- (id) initWithAudioURL:(NSURL *)u delegate:(id<AudioVisualizerViewControllerDelegate>)d;
@end
