//
//  aris_conversationViewController.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneParser.h"
#import "AsyncMediaImageView.h"
#import "Node.h"
#import "Npc.h"
#import "Scene.h"
#import "SceneParser.h"

@interface DialogViewController : UIViewController<SceneParserDelegate, AsyncMediaImageViewDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
	IBOutlet	AsyncMediaImageView	*npcImage;
	IBOutlet	AsyncMediaImageView	*pcImage;
	IBOutlet	UIWebView	*npcWebView;
	IBOutlet	UIWebView	*pcWebView;
	IBOutlet	UITableView	*pcTableView;
	IBOutlet	UITextField	*pcAnswerView;
	IBOutlet	UIScrollView *npcScrollView;
	IBOutlet	UIScrollView *pcScrollView;
	IBOutlet	UIScrollView *npcImageScrollView;
	IBOutlet	UIScrollView *pcImageScrollView;
	IBOutlet	UIActivityIndicatorView *pcActivityIndicator;
	IBOutlet	UILabel		*nothingElseLabel;
	IBOutlet	UIButton	*pcContinueButton;
	IBOutlet	UIButton	*npcContinueButton;
	UIBarButtonItem	*textSizeButton;
    UIBarButtonItem	*specialBackButton;
	
	IBOutlet	UIView	*mainView;
	IBOutlet	UIView	*npcView;
	IBOutlet	UIView	*pcView;
	
	IBOutlet	UITableViewController	*pcTableViewController;
	NSString	*resourcePath;
	
	NSArray			*currentScript;
	NSInteger		scriptIndex;
	NSInteger		lastPcId;
	NSInteger		lastNpcId;
	NSInteger		currentCharacter;
	Scene			*cachedScene;
    NSString        *exitToTabVal;
	UIView			*cachedScrollView;
	SceneParser		*parser;
		
	Npc				*currentNpc;
	Node			*currentNode;
	NSArray			*optionList;

    UILabel         *lbl;
	BOOL			closingScriptPlaying;
	BOOL			inFullScreenTextMode;
}


@property(nonatomic,retain)UILabel *lbl;
@property(nonatomic, retain) IBOutlet AsyncMediaImageView	*npcImage;
@property(nonatomic, retain) IBOutlet AsyncMediaImageView	*pcImage;
@property(nonatomic, retain) IBOutlet UIWebView		*npcWebView;
@property(nonatomic, retain) IBOutlet UIWebView		*pcWebView;
@property(nonatomic, retain) IBOutlet UITableView	*pcTableView;
@property(nonatomic, retain) IBOutlet UITextField	*pcAnswerView;
@property(nonatomic, retain) IBOutlet UILabel		*nothingElseLabel;
@property(nonatomic, retain) IBOutlet UIButton *npcContinueButton;
@property(nonatomic, retain) IBOutlet UIButton *pcContinueButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *textSizeButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *specialBackButton;

@property(nonatomic, retain) IBOutlet NSString *exitToTabVal;

@property(nonatomic, retain) IBOutlet UIScrollView	*npcScrollView;
@property(nonatomic, retain) IBOutlet UIScrollView	*pcScrollView;
@property(nonatomic, retain) IBOutlet UIScrollView	*npcImageScrollView;
@property(nonatomic, retain) IBOutlet UIScrollView	*pcImageScrollView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *pcActivityIndicator;

@property(nonatomic,retain) Npc *currentNpc;
@property(nonatomic,retain) Node *currentNode;

@property(nonatomic, retain) IBOutlet UIView		*mainView;
@property(nonatomic, retain) IBOutlet UIView		*npcView;
@property(nonatomic, retain) IBOutlet UIView		*pcView;

- (IBAction)continueButtonTouchAction;
- (IBAction)npcScrollerTouchAction;

- (void) beginWithNPC:(Npc *)aNpc;
- (void) loadNPCImage:(NSInteger)mediaId;
- (void) continueScript;
- (void) didFinishParsing;
- (void) applyNPCWithGreeting;
- (void) applyPlayerOptions;
- (void) finishApplyingPlayerOptions:(NSArray*)options;
- (void) showWaitingIndicatorForPlayerOptions;
- (void) dismissWaitingIndicatorForPlayerOptions;
- (void) imageFinishedLoading;

@end

