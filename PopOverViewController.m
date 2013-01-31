//
//  NewUIExampleViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "PopOverViewController.h"
#import "RootViewController.h"

BOOL shouldPlay;

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
@"  ol"
@"  {"
@"      text-align:left;"
@"  }"
@"	a {color: #000000; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body><p>%@</p></body>"
@"</html>";

@implementation PopOverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear {
    // probably requires custom animation, but can change self.modalTransitionStyle beforehand
  //  backgroundImage = [[UIImageView alloc] initWithImage:[self screenshot]];
  //  backgroundImage.frame = CGRectMake(0, -[[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, self.view.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
  //   [self.view insertSubview:backgroundImage atIndex:0];
    semiTransparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    semiTransparentView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view insertSubview:semiTransparentView atIndex:1];
}

- (void)viewWillDisappear {
    [popOverWebViewMedia stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [popOverWebViewNoMedia stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [backgroundImage removeFromSuperview];
    [semiTransparentView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageView = [[AsyncMediaImageView alloc] init];
    
    [mainViewNoMediaContentView.layer setCornerRadius:10.0];
    [mainViewMediaContentView.layer setCornerRadius:10.0];
    
    [mainViewNoMedia.layer setCornerRadius:15.0f];
    mainViewNoMedia.layer.borderColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f].CGColor;
    mainViewNoMedia.layer.borderWidth = 2.0f;
    
    [mainViewMedia.layer setCornerRadius:15.0f];
    mainViewMedia.layer.borderColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f].CGColor;
    mainViewMedia.layer.borderWidth = 2.0f;
    
    popOverWebViewMedia.scrollView.bounces = NO;
    popOverWebViewNoMedia.scrollView.bounces = NO;
    
    if(!ARISMoviePlayer) ARISMoviePlayer = [[ARISMoviePlayerViewController alloc] init];
    if(!imageView) imageView = [[AsyncMediaImageView alloc] init];
    
    [continueButtonMedia setTitle:NSLocalizedString(@"OkKey", nil) forState:UIControlStateNormal];
    [continueButtonMedia setTitle:NSLocalizedString(@"OkKey", nil) forState:UIControlStateHighlighted];
    [continueButtonNoMedia setTitle:NSLocalizedString(@"OkKey", nil) forState:UIControlStateNormal];
    [continueButtonNoMedia setTitle:NSLocalizedString(@"OkKey", nil) forState:UIControlStateHighlighted];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) setTitle:(NSString *)title description:(NSString *)description webViewText: (NSString *)text andMediaId: (int) mediaId {

    BOOL hasMedia = (mediaId != 0);
    Media *media;
    if(hasMedia) {
        media = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
        if([media.type isEqualToString: kMediaTypeAudio]) hasMedia = NO;
    }
    
    mainViewNoMedia.hidden = hasMedia;
    mainViewMedia.hidden = !hasMedia;
    
    lbl_popOverTitle = hasMedia ? lbl_popOverTitleMedia : lbl_popOverTitleNoMedia;
    lbl_popOverTitle.text = title;
    
    lbl_popOverDescription = hasMedia ? lbl_popOverDescriptionMedia : lbl_popOverDescriptionNoMedia;
    lbl_popOverDescription.text = description;

    popOverWebView = hasMedia ? popOverWebViewMedia : popOverWebViewNoMedia;
    if ([text rangeOfString:@"<html>"].location == NSNotFound) text = [NSString stringWithFormat:kPopOverHtmlTemplate, text];
    [popOverWebView loadHTMLString:text baseURL:nil];
    
    if(mediaId != 0) {
        [ARISMoviePlayer.view removeFromSuperview];
        [imageView removeFromSuperview];
        if([media.type isEqualToString: kMediaTypeVideo]){
            CGRect movieFrame = mediaView.frame;
            movieFrame.origin.x = 0;
            movieFrame.origin.y = 0;
            [ARISMoviePlayer.view setFrame:movieFrame];
            ARISMoviePlayer.view.backgroundColor = [UIColor clearColor];
            for(UIView* subV in ARISMoviePlayer.moviePlayer.view.subviews) subV.backgroundColor = [UIColor clearColor];
            [self playAudioOrVideoFromMedia:media];
        }
        else if([media.type isEqualToString: kMediaTypeAudio]){
            [self playAudioOrVideoFromMedia:media];
        }
        else if([media.type isEqualToString: kMediaTypeImage]){
            CGRect imageFrame = mediaView.frame;
            imageFrame.origin.x = 0;
            imageFrame.origin.y = 0;
            [imageView setFrame:imageFrame];
            [imageView loadImageFromMedia:media];
            [mediaView addSubview: imageView];
            loadingIndicator.hidden = YES;
        }
    }
}

#pragma mark Audio and Video
- (void) playAudioOrVideoFromMedia:(Media*)media {
    
    //temp fix is to not use media.image, but always stream as we do other places like AsyncMediaPlayerButton
    /*
    if(media.image != nil && [media.type isEqualToString: kMediaTypeAudio]){
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
        NSLog(@"PopOver: Playing through MPMoviePlayerController");
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
    if (ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStateStalled) {
        loadingIndicator.hidden = NO;
        [loadingIndicator startAnimating];
        [ARISMoviePlayer.moviePlayer pause];
    }
    else if (ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStatePlayable) {
        [loadingIndicator stopAnimating];
        if(shouldPlay) [ARISMoviePlayer.moviePlayer play];
        loadingIndicator.hidden = YES;
    }
}

#pragma mark audioPlayerDone

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player successfully: (BOOL) flag {
    NSLog(@"PopOver: Audio is done playing");
    NSError* err;
    [[AVAudioSession sharedInstance] setActive: NO error: &err];
    if(err)NSLog(@"PopOver: Ending Audio: Failed with reason: %@", [err localizedDescription]);
}


- (IBAction)continuePressed:(id)sender {
    if(ARISMoviePlayer.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) [ARISMoviePlayer.moviePlayer stop];
    ARISMoviePlayer.moviePlayer.shouldAutoplay = NO;
    shouldPlay = NO;  //all are necessary otherwise can enter state where audio/video is still loading when user presses continue and the music will play unstoppably afterward as it was triggered by autoplay or it was trigerred by the change in state notification
    
   // if(player.isPlaying){
   //     [player stop];
   // }
    
    [[RootViewController sharedRootViewController] showPopOver];
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    popOverWebView.delegate = nil;
    [popOverWebView stopLoading];
}

- (void)viewDidUnload {
    lbl_popOverTitle = nil;
    popOverWebView = nil;
    continueButton = nil;
    lbl_popOverDescription = nil;
    mediaView = nil;
    loadingIndicator = nil;
    mainViewNoMedia = nil;
    mainViewMedia = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end
