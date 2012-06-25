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

@interface DialogViewController : UIViewController<AVAudioPlayerDelegate, SceneParserDelegate, AsyncMediaImageViewDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
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
		
	Npc				*currentNpc;
	Node			*currentNode;
	NSArray			*optionList;

    UILabel         *lbl;
	BOOL			closingScriptPlaying;
	BOOL			inFullScreenTextMode;
    BOOL			areNotifications;
    BOOL            movedForNotifications;
    BOOL            isPC;
    
    CGRect          tempNpcFrame;
    CGRect          tempPcFrame;
    
    AVAudioPlayer *player;
    ARISMoviePlayerViewController *ARISMoviePlayer;
    
    UIActivityIndicatorView *waiting;
    
    int             notificationBarHeight;
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
@property (nonatomic)         CGRect tempNpcFrame;
@property (nonatomic)         CGRect tempPcFrame;
@property (nonatomic)         UIActivityIndicatorView *waiting;
@property                     BOOL closingScriptPlaying;
@property                     BOOL inFullScreenTextMode;
@property                     BOOL areNotifications;
@property                     BOOL movedForNotifications;
@property                     BOOL isPC;
@property (readwrite,assign)  int notificationBarHeight;

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

