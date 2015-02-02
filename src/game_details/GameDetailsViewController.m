//
//  GameDetailsViewController.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "AppModel.h"
#import "GameCommentsViewController.h"

#import "ARISAlertHandler.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"
#import "ARISStarView.h"

@interface GameDetailsViewController() <ARISMediaViewDelegate, ARISWebViewDelegate, GameCommentsViewControllerDelegate, UIWebViewDelegate>
{
    UIScrollView  *scrollView;
    ARISMediaView *mediaView;
    ARISWebView   *descriptionView;

    UIButton *startButton;
    UIButton *resumeButton;
    UIButton *resetButton;
    UIButton *rateButton;

    Game *game;
    BOOL loading_has_been_played;
    BOOL has_been_played;
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

        loading_has_been_played = YES;
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

    resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton setTitle:NSLocalizedString(@"GameDetailsResetKey", nil) forState:UIControlStateNormal];
    [resetButton setBackgroundColor:[UIColor ARISColorRed]];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [ARISTemplate ARISButtonFont];

    rateButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [rateButton setBackgroundColor:[UIColor ARISColorOffWhite]];

    ARISStarView *starView = [[ARISStarView alloc] initWithFrame:CGRectMake(10,10,100,20)];
    starView.rating = game.rating;

    UILabel *reviewsTextView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-110,12,100,15)];
    reviewsTextView.font = [ARISTemplate ARISButtonFont];
    reviewsTextView.text = [NSString stringWithFormat:@"%ld %@",(unsigned long)game.comments.count, NSLocalizedString(@"ReviewsKey", @"")];

    [rateButton addSubview:starView];
    [rateButton addSubview:reviewsTextView];

    [startButton addTarget:self action:@selector(startButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [resumeButton addTarget:self action:@selector(startButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [resetButton addTarget:self action:@selector(resetButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [rateButton  addTarget:self action:@selector(rateButtonTouched)  forControlEvents:UIControlEventTouchUpInside];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    [self.view addSubview:scrollView];

    [self loadGame];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refreshFromGame];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
    rateButton.frame = CGRectMake(0, startButton.frame.origin.y-40, self.view.bounds.size.width, 40);

    scrollView.frame = self.view.bounds;
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height-64-44);

    startButton.frame = CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40);
    resumeButton.frame = CGRectMake((self.view.bounds.size.width/2),self.view.bounds.size.height-40,(self.view.bounds.size.width/2),40);
    resetButton.frame = CGRectMake(0,self.view.bounds.size.height-40,(self.view.bounds.size.width/2),40);
}


- (void) loadGame
{
    [scrollView addSubview:descriptionView];
    descriptionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);//Needs correct width to calc height

    [scrollView addSubview:mediaView];
    [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
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

    [startButton removeFromSuperview];
    [resumeButton removeFromSuperview];
    [resetButton removeFromSuperview];
    if(loading_has_been_played)
    {
    }
    else if(has_been_played)
    {
        [self.view addSubview:resetButton];
        [self.view addSubview:resumeButton];
    }
    else
    {
        [self.view addSubview:startButton];
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
        has_been_played = NO;
        [self refreshFromGame];
    }
}

- (void) gamePlayedReceived:(NSNotification *)notif
{
    has_been_played = [notif.userInfo[@"has_played"] boolValue];
    loading_has_been_played = NO;
    [self refreshFromGame];
}

//implement statecontrol stuff for webpage, but ignore any requests
- (BOOL) displayTrigger:(Trigger *)t   { return NO; }
- (BOOL) displayTriggerId:(long)t       { return NO; }
- (BOOL) displayInstance:(Instance *)i { return NO; }
- (BOOL) displayInstanceId:(long)i      { return NO; }
- (BOOL) displayObject:(id)o           { return NO; }
- (BOOL) displayObjectType:(NSString *)type id:(long)type_id { return NO; }
- (void) displayTab:(Tab *)t           { }
- (void) displayTabId:(long)t           { }
- (void) displayTabType:(NSString *)t  { }
- (void) displayScannerWithPrompt:(NSString *)p { }

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
