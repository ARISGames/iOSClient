//
//  aris_conversationViewController.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneParser.h"

@class AsyncImageView;
@class AudioStreamer;
@class AVAudioPlayer;
@class Node;

@interface DialogViewController : UIViewController<SceneParserDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	AsyncImageView	*npcImage;
	AsyncImageView	*pcImage;
	UIWebView	*npcWebView;
	UIWebView	*pcWebView;
	UITableView	*pcTableView;
	UITextField	*pcAnswerView;
	UIScrollView *npcScrollView;
	UIScrollView *pcScrollView;
	UILabel		 *pcLabel;
	UILabel *nothingElseLabel;
	
	UIView	*mainView;
	UIView	*npcView;
	UIView	*pcView;
	
	UITableViewController	*pcTableViewController;
	NSString	*resourcePath;
	
	NSArray			*currentScript;
	NSInteger		scriptIndex;
	NSInteger		lastPcId;
	NSInteger		lastNpcId;
	NSInteger		currentCharacter;
	Scene			*cachedScene;

	UIView			*cachedScrollView;
	SceneParser		*parser;
	
	AudioStreamer	*bgPlayer;
	AudioStreamer	*fgPlayer;
	
	Npc				*currentNpc;
	Node			*currentNode;
	NSMutableArray	*optionList;
}

@property(nonatomic, retain) IBOutlet AsyncImageView	*npcImage;
@property(nonatomic, retain) IBOutlet AsyncImageView	*pcImage;
@property(nonatomic, retain) IBOutlet UIWebView		*npcWebView;
@property(nonatomic, retain) IBOutlet UIWebView		*pcWebView;
@property(nonatomic, retain) IBOutlet UITableView	*pcTableView;
@property(nonatomic, retain) IBOutlet UITextField	*pcAnswerView;
@property(nonatomic, retain) IBOutlet UILabel		*pcLabel;
@property(nonatomic, retain) IBOutlet UILabel		*nothingElseLabel;


@property(nonatomic, retain) IBOutlet UIScrollView	*npcScrollView;
@property(nonatomic, retain) IBOutlet UIScrollView	*pcScrollView;

@property(nonatomic, retain) IBOutlet UIView		*mainView;
@property(nonatomic, retain) IBOutlet UIView		*npcView;
@property(nonatomic, retain) IBOutlet UIView		*pcView;

- (void) beginWithNPC:(Npc *)aNpc;
- (void) loadPCImage:(NSInteger)mediaId;
- (void) loadNPCImage:(NSInteger)mediaId;
- (void) continueScript;
- (void) didFinishParsing;

@end

