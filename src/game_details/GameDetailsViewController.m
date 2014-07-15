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

#import "StateControllerProtocol.h"

@interface GameDetailsViewController() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol, GameCommentsViewControllerDelegate, UIWebViewDelegate>
{
    ARISMediaView *mediaView;
    ARISWebView *descriptionView;
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
    
    mediaView = [[ARISMediaView alloc] initWithDelegate:self];
    [mediaView setDisplayMode:ARISMediaDisplayModeAspectFit];
    
    descriptionView = [[ARISWebView alloc] initWithDelegate:self];
    
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
    reviewsTextView.text = [NSString stringWithFormat:@"%d %@",game.comments.count, NSLocalizedString(@"ReviewsKey", @"")];
    
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
    
    [self.view addSubview:mediaView];
    [self.view addSubview:rateButton];
    [self.view addSubview:descriptionView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 
    
    [self refreshFromGame]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [mediaView setFrame:CGRectMake(0,0+64,self.view.bounds.size.width,200)];
    rateButton.frame = CGRectMake(0, startButton.frame.origin.y-40, self.view.bounds.size.width, 40);
    descriptionView.frame = CGRectMake(0,200+64,self.view.bounds.size.width,rateButton.frame.origin.y-(200+64));
}

- (void) refreshFromGame
{
    self.title = game.name; 
    
    if(![game.desc isEqualToString:@""])
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
        startButton.frame = CGRectMake((self.view.bounds.size.width/2),self.view.bounds.size.height-40,(self.view.bounds.size.width/2),40);
        resetButton.frame = CGRectMake(0,self.view.bounds.size.height-40,(self.view.bounds.size.width/2),40);
        [self.view addSubview:resetButton];
        [self.view addSubview:resumeButton];
    }
    else
    {
        startButton.frame = CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40);
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
        [_MODEL_LOGS_ playerResetGame:game.game_id];
        startButton.enabled =NO;
        has_been_played = NO;
        [self refreshFromGame];
    }
}

- (void) gamePlayedReceived:(NSNotification *)notif
{
    has_been_played = notif.userInfo[@"has_played"];
    loading_has_been_played = NO;
    [self refreshFromGame];
}

//implement statecontrol stuff for webpage, but ignore any requests
- (void) displayTab:(NSString *)t {}
- (BOOL) displayGameObject:(id)g fromSource:(id)s {return NO;}
- (void) displayScannerWithPrompt:(NSString *)p {}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);    
}

@end
