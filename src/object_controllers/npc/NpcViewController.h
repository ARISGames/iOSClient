//
//  aris_conversationViewController.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "GameObjectViewController.h"

@class Npc;
@class Node;
@protocol StateControllerProtocol;

@interface NpcViewController : GameObjectViewController
{
    Npc  *currentNpc;
	Node *currentNode;
}

@property (nonatomic, strong) Npc *currentNpc;
@property (nonatomic, strong) Node *currentNode;

- (id) initWithNpc:(Npc *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d;
- (void) showWaitingIndicatorForPlayerOptions;

@end
