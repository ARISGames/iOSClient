//
//  NpcViewController.h
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "GameObjectViewController.h"

@class Npc;
@protocol StateControllerProtocol;

@interface NpcViewController : GameObjectViewController
- (id) initWithNpc:(Npc *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d;
@end
