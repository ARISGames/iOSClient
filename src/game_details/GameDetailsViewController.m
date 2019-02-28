//
//  GameDetailsViewController.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "GameCommentsViewController.h"

#import "ARISAlertHandler.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"
#import "ARISStarView.h"
#import <Google/Analytics.h>


@interface GameDetailsViewController() <ARISMediaViewDelegate, ARISWebViewDelegate, GameCommentsViewControllerDelegate, UIWebViewDelegate>
{
  UIScrollView  *scrollView;
  ARISMediaView *mediaView;
  ARISWebView   *descriptionView;

  UIButton *resetButton;
  UIButton *startButton;
  UIButton *resumeButton;
  UIButton *rateButton;

  Game *game;
  id<GameDetailsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GameDetailsViewController

- (id) initWithGame:(Game *)g delegate:(id<GameDetailsViewControllerDelegate>)d
{
  if(self = [super init])
  {
    delegate = d;
    game = g;
    _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_PLAYED_GAME_AVAILABLE", self, @selector(gamePlayedReceived:), nil);

    game.know_if_begin_fresh = NO; //we'll double check right now anyways
    [_MODEL_GAMES_ requestPlayerPlayedGame:game.game_id];
  }
  return self;
}

- (void) loadView
{
  [super loadView];

  self.view.backgroundColor = [UIColor whiteColor];

  scrollView = [[UIScrollView alloc] init];
  scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
  scrollView.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
  scrollView.clipsToBounds = NO;

  mediaView = [[ARISMediaView alloc] initWithDelegate:self];
  [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight];

  descriptionView = [[ARISWebView alloc] initWithDelegate:self];
  descriptionView.backgroundColor = [UIColor clearColor];
  descriptionView.scrollView.bounces = NO;
  descriptionView.scrollView.scrollEnabled = NO;
  descriptionView.alpha = 0.0; //The descriptionView will resore alpha once it's loaded to avoid the ugly white blob

  resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [resetButton setTitle:NSLocalizedString(@"GameDetailsResetKey", nil) forState:UIControlStateNormal];
  [resetButton setBackgroundColor:[UIColor ARISColorRed]];
  [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  resetButton.titleLabel.font = [ARISTemplate ARISButtonFont];

  startButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [startButton setTitle:NSLocalizedString(@"GameDetailsNewGameKey", @"") forState:UIControlStateNormal];
  [startButton setBackgroundColor:[UIColor ARISColorLightBlue]];
  [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  startButton.titleLabel.font = [ARISTemplate ARISButtonFont];

  resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [resumeButton setTitle:NSLocalizedString(@"GameDetailsResumeKey", @"") forState:UIControlStateNormal];
  [resumeButton setBackgroundColor:[UIColor ARISColorLightBlue]];
  [resumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  resumeButton.titleLabel.font = [ARISTemplate ARISButtonFont];

  rateButton  = [UIButton buttonWithType:UIButtonTypeCustom];
  [rateButton setBackgroundColor:[UIColor ARISColorOffWhite]];

  ARISStarView *starView = [[ARISStarView alloc] initWithFrame:CGRectMake(10,10,100,20)];
  starView.rating = game.rating;

  UILabel *reviewsTextView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-110,12,100,15)];
  reviewsTextView.font = [ARISTemplate ARISButtonFont];
  reviewsTextView.text = [NSString stringWithFormat:@"%ld %@",(unsigned long)game.comments.count, NSLocalizedString(@"ReviewsKey", @"")];

  [rateButton addSubview:starView];
  [rateButton addSubview:reviewsTextView];

  [resetButton  addTarget:self action:@selector(resetButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  [startButton  addTarget:self action:@selector(startButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  [resumeButton addTarget:self action:@selector(startButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  [rateButton   addTarget:self action:@selector(rateButtonTouched)  forControlEvents:UIControlEventTouchUpInside];

  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  backButton.frame = CGRectMake(0, 0, 27, 27);
  [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
  backButton.accessibilityLabel = @"Back Button";
  [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

  descriptionView.frame = CGRectMake(0,0,self.view.bounds.size.width,10);//Needs correct width to calc height
  mediaView.frame       = CGRectMake(0,0,self.view.bounds.size.width,20);

  [scrollView addSubview:descriptionView];
  [scrollView addSubview:mediaView];
  [self.view addSubview:scrollView];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self refreshFromGame];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Game Details"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
  rateButton.frame = CGRectMake(0, startButton.frame.origin.y-40, self.view.bounds.size.width, 40);

  scrollView.frame = self.view.bounds;
  scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
  scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height-64-44);

  [self refreshFromGame];
}

- (void) ARISMediaViewFrameUpdated:(ARISMediaView *)amv
{
  descriptionView.frame  = CGRectMake(0, mediaView.frame.size.height, self.view.bounds.size.width, descriptionView.frame.size.height);
  scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,descriptionView.frame.origin.y+descriptionView.frame.size.height+10);
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
  descriptionView.alpha = 1.00;

  //Calculate the height of the web content
  float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
  if(![game.desc isEqualToString:@""])
  {
    [descriptionView setFrame:CGRectMake(descriptionView.frame.origin.x,
                                       descriptionView.frame.origin.y,
                                       descriptionView.frame.size.width,
                                       newHeight)];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,descriptionView.frame.origin.y+descriptionView.frame.size.height);
  }
  else
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,descriptionView.frame.origin.y);
}

- (void) refreshFromGame
{
  self.title = game.name;

  [descriptionView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], game.desc] baseURL:nil];

  if(game.media_id) [mediaView setMedia:[_MODEL_MEDIA_ mediaForId:game.media_id]];
  else              [mediaView setImage:[UIImage imageNamed:@"DefaultGameSplash"]];

  [resetButton removeFromSuperview];
  [startButton removeFromSuperview];
  [resumeButton removeFromSuperview];

  long n_buttons = 0;
  long b_y = self.view.bounds.size.height-40;
  long b_h = 40;
  
  if(game.know_if_begin_fresh && game.begin_fresh)
  {
    n_buttons++; //start
    long b_w = self.view.bounds.size.width/n_buttons;
    
    long i = 0;
    startButton.frame = CGRectMake(b_w*i,b_y,b_w,b_h); i++;
    [self.view addSubview:startButton];
  }
  else if(game.know_if_begin_fresh && !game.begin_fresh)
  {
    n_buttons++; //resume
    n_buttons++; //reset
    long b_w = self.view.bounds.size.width/n_buttons;
    
    long i = 0;
    resetButton.frame = CGRectMake(b_w*i,b_y,b_w,b_h); i++;
    resumeButton.frame = CGRectMake(b_w*i,b_y,b_w,b_h); i++;
    [self.view addSubview:resetButton];
    [self.view addSubview:resumeButton];
  }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  NSURL *requestURL = [request URL];

  if(([[requestURL scheme] isEqualToString:@"http"] ||
      [[requestURL scheme] isEqualToString:@"https"]) &&
     (navigationType == UIWebViewNavigationTypeLinkClicked))
      return ![[UIApplication sharedApplication] openURL:requestURL];

  return YES;
}

- (void) startButtonTouched
{
  [_MODEL_ chooseGame:game];
}

- (void) resetButtonTouched
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameDetailsResetTitleKey", nil) message:NSLocalizedString(@"GameDetailsResetMessageKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"GameDetailsResetKey", @""), nil];
  [alert show];
}

- (void) rateButtonTouched
{
  GameCommentsViewController *commentsVC = [[GameCommentsViewController alloc] initWithGame:game delegate:self];
  [self.navigationController pushViewController:commentsVC animated:YES];
}

- (void) backButtonTouched
{
  [delegate gameDetailsCanceled:game];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(buttonIndex == 1)
  {
    [_MODEL_GAMES_ playerResetGame:game.game_id];
    game.begin_fresh = YES;
    [self refreshFromGame];
  }
}

- (void) gamePlayedReceived:(NSNotification *)notif
{
  game.begin_fresh = ![notif.userInfo[@"has_played"] boolValue];
  game.know_if_begin_fresh = YES;
  [self refreshFromGame];
}

//implement statecontrol stuff for webpage, but ignore any requests
- (BOOL) displayTrigger:(Trigger *)t   { return NO; }
- (BOOL) displayTriggerId:(long)t      { return NO; }
- (BOOL) displayInstance:(Instance *)i { return NO; }
- (BOOL) displayInstanceId:(long)i     { return NO; }
- (BOOL) displayObject:(id)o           { return NO; }
- (BOOL) displayObjectType:(NSString *)type id:(long)type_id { return NO; }
- (void) displayTab:(Tab *)t           { }
- (void) displayTabId:(long)t          { }
- (void) displayTabType:(NSString *)t  { }

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
