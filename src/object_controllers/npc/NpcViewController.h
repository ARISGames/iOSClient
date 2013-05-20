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
#import "SceneParser.h"
#import "AsyncMediaImageView.h"
#import "Node.h"
#import "Npc.h"

#import "StateControllerProtocol.h"

@interface NpcViewController : GameObjectViewController <SceneParserDelegate, AsyncMediaImageViewDelegate, GameObjectViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
{
    IBOutlet UIView	*pcView;
    IBOutlet UIScrollView *pcImageSection;
    IBOutlet AsyncMediaImageView *pcImageView;
	IBOutlet UIScrollView *pcTextSection;
    IBOutlet UIWebView *pcTextWebView;
    IBOutlet UITableView *pcOptionsTable;
    IBOutlet UIButton *pcTapToContinueButton;

	IBOutlet UIView	*npcView;
    IBOutlet UIScrollView *npcImageSection;
	IBOutlet AsyncMediaImageView *npcImageView;
    IBOutlet UIScrollView *npcVideoView;
	IBOutlet UIScrollView *npcTextSection;
    IBOutlet UIWebView *npcTextWebView;
	IBOutlet UIButton *npcTapToContinueButton;
    
    Npc  *currentNpc;
	Node *currentNode;
}

@property (nonatomic, strong) IBOutlet UIView *pcView;
@property (nonatomic, strong) IBOutlet UIScrollView *pcImageSection;
@property (nonatomic, strong) IBOutlet AsyncMediaImageView *pcImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *pcTextSection;
@property (nonatomic, strong) IBOutlet UIWebView *pcTextWebView;
@property (nonatomic, strong) IBOutlet UITableView *pcOptionsTable;
@property (nonatomic, strong) IBOutlet UIButton *pcTapToContinueButton;

@property (nonatomic, strong) IBOutlet UIView *npcView;
@property (nonatomic, strong) IBOutlet UIScrollView *npcImageSection;
@property (nonatomic, strong) IBOutlet AsyncMediaImageView *npcImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *npcVideoView;
@property (nonatomic, strong) IBOutlet UIScrollView *npcTextSection;
@property (nonatomic, strong) IBOutlet UIWebView *npcTextWebView;
@property (nonatomic, strong) IBOutlet UIButton *npcTapToContinueButton;

@property (nonatomic, strong) Npc *currentNpc;
@property (nonatomic, strong) Node *currentNode;

- (id) initWithNpc:(Npc *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d;

- (IBAction)continueButtonTouchAction;

- (void) showWaitingIndicatorForPlayerOptions;

@end
