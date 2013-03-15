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

@interface DialogViewController : UIViewController <SceneParserDelegate, AsyncMediaImageViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
{
	IBOutlet AsyncMediaImageView *npcImage;
	IBOutlet AsyncMediaImageView *pcImage;
	IBOutlet UIWebView *npcWebView;
	IBOutlet UIWebView *pcWebView;
	IBOutlet UITableView *pcTableView;
	IBOutlet UITextField *pcAnswerView;
	IBOutlet UIScrollView *npcScrollView;
	IBOutlet UIScrollView *pcScrollView;
	IBOutlet UIScrollView *npcImageScrollView;
	IBOutlet UIScrollView *pcImageScrollView;
	IBOutlet UIActivityIndicatorView *pcActivityIndicator;
	IBOutlet UILabel *nothingElseLabel;
	IBOutlet UIButton *pcContinueButton;
	IBOutlet UIButton *npcContinueButton;
	UIBarButtonItem	*textSizeButton;
    UIBarButtonItem	*specialBackButton;
	
	IBOutlet UIView	*mainView;
	IBOutlet UIView	*npcView;
	IBOutlet UIView	*pcView;
    IBOutlet UIScrollView *npcVideoView;
	
	IBOutlet UITableViewController *pcTableViewController;
	NSString *resourcePath;
	
	NSArray *currentScript;
	NSInteger scriptIndex;
	NSInteger lastPcId;
	NSInteger lastNpcId;
	Scene *cachedScene;
    NSString *exitToTabVal;
	UIView *cachedScrollView;
	SceneParser *parser;
	
	NSString *pcTitle;
    NSString *leaveButtonTitle;
    
	Npc  *currentNpc;
	Node *currentNode;
	NSArray *optionList;

    UILabel *lbl;
	int textboxSize;
    BOOL closingScriptPlaying;
    BOOL hideLeaveConversationButton;
    
    AVAudioPlayer *player;
    ARISMoviePlayerViewController *ARISMoviePlayer;
    
    UIActivityIndicatorView *waiting;
}

@property (nonatomic, strong) UILabel *lbl;
@property (nonatomic, strong) IBOutlet AsyncMediaImageView *npcImage;
@property (nonatomic, strong) IBOutlet AsyncMediaImageView *pcImage;
@property (nonatomic, strong) IBOutlet UIWebView *npcWebView;
@property (nonatomic, strong) IBOutlet UIWebView *pcWebView;
@property (nonatomic, strong) IBOutlet UITableView *pcTableView;
@property (nonatomic, strong) IBOutlet UITextField *pcAnswerView;
@property (nonatomic, strong) IBOutlet UILabel *nothingElseLabel;
@property (nonatomic, strong) IBOutlet UIButton *npcContinueButton;
@property (nonatomic, strong) IBOutlet UIButton *pcContinueButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *textSizeButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *specialBackButton;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) ARISMoviePlayerViewController *ARISMoviePlayer;
@property (nonatomic, strong) UIActivityIndicatorView *waiting;
@property (nonatomic, assign) BOOL closingScriptPlaying;
@property (nonatomic, assign) int textboxSize;
@property (nonatomic, assign) BOOL hideLeaveConversationButton;

@property(nonatomic, strong) IBOutlet NSString *exitToTabVal;

@property(nonatomic, strong) IBOutlet UIScrollView *npcScrollView;
@property(nonatomic, strong) IBOutlet UIScrollView *pcScrollView;
@property(nonatomic, strong) IBOutlet UIScrollView *npcImageScrollView;
@property(nonatomic, strong) IBOutlet UIScrollView *pcImageScrollView;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *pcActivityIndicator;

@property(nonatomic, strong) Npc *currentNpc;
@property(nonatomic, strong) Node *currentNode;

@property(nonatomic, strong) IBOutlet UIView *mainView;
@property(nonatomic, strong) IBOutlet UIView *npcView;
@property(nonatomic, strong) IBOutlet UIView *pcView;
@property(nonatomic, strong) IBOutlet UIScrollView *npcVideoView;

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
