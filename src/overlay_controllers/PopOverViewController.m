//
//  NewUIExampleViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "PopOverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "PopOverContentView.h"
#import "AsyncMediaImageView.h"
#import "ARISMoviePlayerViewController.h"
#import "Media.h"

NSString *const kPopOverHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"  html,body {margin: 0;padding: 0;width: 100%%;height: 100%%;}"
@"  html {display: table;}"
@"	body {"
@"		background-color: transparent;"
@"		color: #000000;"
@"      display: table-cell;"
@"      vertical-align: middle;"
@"      text-align: center;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      -webkit-text-size-adjust: none;"
@"	}"
@"  ul,ol"
@"  {"
@"      text-align:left;"
@"  }"
@"	a {color: #000000; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body><p>%@</p></body>"
@"</html>";

@interface PopOverViewController() <AsyncMediaImageViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate>
{
    BOOL shouldPlay;

    IBOutlet PopOverContentView *mainViewNoMedia;
    IBOutlet PopOverContentView *mainViewMedia;
    IBOutlet UIView *mainViewNoMediaContentView;
    IBOutlet UIView *mainViewMediaContentView;
    UIView *mainView;
    
    IBOutlet UILabel *lbl_popOverTitleNoMedia;
    IBOutlet UILabel *lbl_popOverTitleMedia;
    UILabel *lbl_popOverTitle;
    
    IBOutlet UILabel *lbl_popOverDescriptionNoMedia;
    IBOutlet UILabel *lbl_popOverDescriptionMedia;
    UILabel *lbl_popOverDescription;
    
    IBOutlet UIWebView *popOverWebViewNoMedia;
    IBOutlet UIWebView *popOverWebViewMedia;
    UIWebView *popOverWebView;
    
    IBOutlet UIButton *continueButtonNoMedia;
    IBOutlet UIButton *continueButtonMedia;
    UIButton *continueButton;
    
    IBOutlet UIView *mediaView;
    IBOutlet UIActivityIndicatorView *loadingIndicator;
        
    AVAudioPlayer *player;
    ARISMoviePlayerViewController *ARISMoviePlayer;
    AsyncMediaImageView	*imageView;
    
    id<PopOverViewDelegate> __unsafe_unretained delegate;
}
- (IBAction) continuePressed:(id)sender;

@end

@implementation PopOverViewController

- (id)initWithDelegate:(id <PopOverViewDelegate>)poDelegate
{
    if(self = [super initWithNibName:@"PopOverViewController" bundle:nil])
    {
        delegate = poDelegate;
    }
    return self;
}

- (void)viewWillDisappear
{
    [popOverWebViewMedia   stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [popOverWebViewNoMedia stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [mainViewNoMediaContentView.layer setCornerRadius:10.0];
    [mainViewMediaContentView.layer   setCornerRadius:10.0];
    [mainViewNoMedia.layer setCornerRadius:15.0f];
    [mainViewMedia.layer   setCornerRadius:15.0f];
    mainViewNoMedia.layer.borderColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f].CGColor;
    mainViewMedia.layer.borderColor   = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f].CGColor;
    mainViewNoMedia.layer.borderWidth = 2.0f;
    mainViewMedia.layer.borderWidth   = 2.0f;
    popOverWebViewMedia.scrollView.bounces   = NO;
    popOverWebViewNoMedia.scrollView.bounces = NO;
    
    if(!ARISMoviePlayer) ARISMoviePlayer = [[ARISMoviePlayerViewController alloc] init];
    if(!imageView)             imageView = [[AsyncMediaImageView           alloc] init];
    
    [continueButtonMedia   setTitle:NSLocalizedString(@"OkKey", nil) forState:UIControlStateNormal];
    [continueButtonNoMedia setTitle:NSLocalizedString(@"OkKey", nil) forState:UIControlStateNormal];
}

- (void) setTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int)mediaId
{
    if(!self.view) self.view.hidden = NO; //Just accesses view to force its load
    
    BOOL hasMedia = (mediaId != 0);
    Media *media;
    if(hasMedia)
    {
        //PHIL media = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
        if([media.type isEqualToString:@"AUDIO"]) hasMedia = NO;
    }
    
    mainViewNoMedia.hidden = hasMedia;
    mainViewMedia.hidden = !hasMedia;
    
    lbl_popOverTitle = hasMedia ? lbl_popOverTitleMedia : lbl_popOverTitleNoMedia;
    lbl_popOverTitle.text = title;
    
    lbl_popOverDescription = hasMedia ? lbl_popOverDescriptionMedia : lbl_popOverDescriptionNoMedia;
    lbl_popOverDescription.text = description;

    popOverWebView = hasMedia ? popOverWebViewMedia : popOverWebViewNoMedia;
    if([text rangeOfString:@"<html>"].location == NSNotFound) text = [NSString stringWithFormat:kPopOverHtmlTemplate, text];
    [popOverWebView loadHTMLString:text baseURL:nil];
    
    if(mediaId != 0)
    {
        [ARISMoviePlayer.view removeFromSuperview];
        [imageView removeFromSuperview];
        if([media.type isEqualToString:@"VIDEO"])
        {
            [ARISMoviePlayer.view setFrame:CGRectMake(0,0,mediaView.frame.size.width,mediaView.frame.size.height)];
            ARISMoviePlayer.view.backgroundColor = [UIColor clearColor];
            for(UIView* subV in ARISMoviePlayer.moviePlayer.view.subviews) subV.backgroundColor = [UIColor clearColor];
            [self playAudioOrVideoFromMedia:media];
        }
        else if([media.type isEqualToString:@"AUDIO"])
            [self playAudioOrVideoFromMedia:media];
        else if([media.type isEqualToString:@"PHOTO"])
        {
            [imageView setFrame:CGRectMake(0,0,mediaView.frame.size.width,mediaView.frame.size.height)];
            [imageView loadMedia:media];
            [mediaView addSubview: imageView];
            loadingIndicator.hidden = YES;
        }
    }
}

#pragma mark Audio and Video
- (void) playAudioOrVideoFromMedia:(Media*)media
{    
    //temp fix is to not use media.image, but always stream as we do other places like AsyncMediaPlayerButton
    /*
    if(media.image != nil && [media.type isEqualToString:@"AUDIO"]){
        NSLog(@"PopOver: Playing through AVAudioPlayer");
        NSError* err;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &err];
        [[AVAudioSession sharedInstance] setActive: YES error: &err];
        player = [[AVAudioPlayer alloc] initWithData: media.image error:&err];
        [player setDelegate: self];
        [player prepareToPlay];
        
        if( err )NSLog(@"PopOver: Playing Audio: Failed with reason: %@", [err localizedDescription]);
        else [player play];
        
    }
    */
  //  else{
        shouldPlay = YES;
        [mediaView insertSubview: ARISMoviePlayer.view belowSubview:loadingIndicator];
        ARISMoviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeUnknown;
        [ARISMoviePlayer.moviePlayer setContentURL: [NSURL URLWithString:media.url]];
        [ARISMoviePlayer.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [ARISMoviePlayer.moviePlayer setFullscreen:NO];
        [ARISMoviePlayer.moviePlayer prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:ARISMoviePlayer.moviePlayer];
        ARISMoviePlayer.moviePlayer.shouldAutoplay = YES;
        loadingIndicator.hidden = NO;
        loadingIndicator.hidesWhenStopped = YES;
        [loadingIndicator startAnimating];
  //  }
}

#pragma mark MPMoviePlayerController notifications

- (void)MPMoviePlayerLoadStateDidChangeNotification:(NSNotification *)notif
{
    if(ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStateStalled)
    {
        loadingIndicator.hidden = NO;
        [loadingIndicator startAnimating];
        [ARISMoviePlayer.moviePlayer pause];
    }
    else if(ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStatePlayable)
    {
        [loadingIndicator stopAnimating];
        if(shouldPlay) [ARISMoviePlayer.moviePlayer play];
        loadingIndicator.hidden = YES;
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSError* err;
    [[AVAudioSession sharedInstance] setActive: NO error: &err];
    if(err)NSLog(@"PopOver: Ending Audio: Failed with reason: %@", [err localizedDescription]);
}

- (IBAction) continuePressed:(id)sender
{
    if(ARISMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) [ARISMoviePlayer.moviePlayer stop];
    
    ARISMoviePlayer.moviePlayer.shouldAutoplay = NO;
    shouldPlay = NO;  //all are necessary otherwise can enter state where audio/video is still loading when user presses continue and the music will play unstoppably afterward as it was triggered by autoplay or it was trigerred by the change in state notification
    
    //if(player.isPlaying){
    //  [player stop];
    //}
    
    [delegate popOverContinueButtonPressed];
}

- (NSInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end