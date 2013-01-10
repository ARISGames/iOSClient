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

@interface DialogViewController : UIViewController<SceneParserDelegate, AsyncMediaImageViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, AVAudioPlayerDelegate> {
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
    IBOutlet	UIScrollView	*npcVideoView;
	
	IBOutlet	UITableViewController	*pcTableViewController;
	NSString	*resourcePath;
	
	NSArray			*currentScript;
	NSInteger		scriptIndex;
	NSInteger		lastPcId;
	NSInteger		lastNpcId;
	Scene			*cachedScene;
    NSString        *exitToTabVal;
	UIView			*cachedScrollView;
	SceneParser		*parser;
	
	NSString        *pcTitle;
    NSString        *leaveButtonTitle;
    
	Npc				*currentNpc;
	Node			*currentNode;
	NSArray			*optionList;

    UILabel         *lbl;
	BOOL			closingScriptPlaying;
	int			    textboxSize;
    BOOL            hideLeaveConversationButton;
    
    AVAudioPlayer *player;
    ARISMoviePlayerViewController *ARISMoviePlayer;
    
    UIActivityIndicatorView *waiting;
}


@property(nonatomic)UILabel *lbl;
@property(nonatomic) IBOutlet AsyncMediaImageView	*npcImage;
@property(nonatomic) IBOutlet AsyncMediaImageView	*pcImage;
@property(nonatomic) IBOutlet UIWebView		*npcWebView;
@property(nonatomic) IBOutlet UIWebView		*pcWebView;
@property(nonatomic) IBOutlet UITableView	*pcTableView;
@property(nonatomic) IBOutlet UITextField	*pcAnswerView;
@property(nonatomic) IBOutlet UILabel		*nothingElseLabel;
@property(nonatomic) IBOutlet UIButton *npcContinueButton;
@property(nonatomic) IBOutlet UIButton *pcContinueButton;
@property(nonatomic) IBOutlet UIBarButtonItem *textSizeButton;
@property(nonatomic) IBOutlet UIBarButtonItem *specialBackButton;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) ARISMoviePlayerViewController *ARISMoviePlayer;
@property (nonatomic)         UIActivityIndicatorView *waiting;
@property                     BOOL closingScriptPlaying;
@property                     int textboxSize;
@property                     BOOL            hideLeaveConversationButton;

@property(nonatomic) IBOutlet NSString *exitToTabVal;

@property(nonatomic) IBOutlet UIScrollView	*npcScrollView;
@property(nonatomic) IBOutlet UIScrollView	*pcScrollView;
@property(nonatomic) IBOutlet UIScrollView	*npcImageScrollView;
@property(nonatomic) IBOutlet UIScrollView	*pcImageScrollView;
@property(nonatomic) IBOutlet UIActivityIndicatorView *pcActivityIndicator;

@property(nonatomic) Npc *currentNpc;
@property(nonatomic) Node *currentNode;

@property(nonatomic) IBOutlet UIView		*mainView;
@property(nonatomic) IBOutlet UIView		*npcView;
@property(nonatomic) IBOutlet UIView		*pcView;
@property(nonatomic) IBOutlet UIScrollView		*npcVideoView;

- (IBAction)continueButtonTouchAction;
- (IBAction)npcScrollerTouchAction;

- (void) beginWithNPC:(Npc *)aNpc;
- (void) loadNPCImage:(NSInteger)mediaId;
- (void) continueScript;
- (void) fixTextBox;
- (void) didFinishParsing;
- (void) applyNPCWithGreeting;
- (void) applyPlayerOptions;
- (void) finishApplyingPlayerOptions:(NSArray*)options;
- (void) showWaitingIndicatorForPlayerOptions;
- (void) dismissWaitingIndicatorForPlayerOptions;
- (void) imageFinishedLoading;
- (void) playAudioOrVideoFromMedia:(Media*)media andHidden:(BOOL)hidden;
- (void) MPMoviePlayerLoadStateDidChangeNotification:(NSNotification *)notif;

@end

