//
//  NewUIExampleViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "PopOverViewController.h"
#import "RootViewController.h"

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

- (void)viewWillAppear:(BOOL)animated {
    
    // probably requires custom animation, but can change self.modalTransitionStyle beforehand
    backgroundImage = [[UIImageView alloc] initWithImage:[self screenshot]];
    backgroundImage.frame = CGRectMake(0, -[[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, self.view.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height);
    [self.view insertSubview:backgroundImage atIndex:0];
    semiTransparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    semiTransparentView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view insertSubview:semiTransparentView atIndex:1];
    
    if(!player) player = [[AVAudioPlayer alloc] init];
    if(!ARISMoviePlayer) ARISMoviePlayer = [[ARISMoviePlayerViewController alloc] init];
    if(!imageView) imageView = [[AsyncMediaImageView alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated {
    [backgroundImage removeFromSuperview];
    [semiTransparentView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageView = [[AsyncMediaImageView alloc] init];
    
    [mainViewNoMedia.layer setCornerRadius:15.0];
    mainViewNoMedia.layer.borderColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;// [UIColor grayColor].CGColor;
    mainViewNoMedia.layer.borderWidth = 3.0f;
    
    [mainViewMedia.layer setCornerRadius:15.0];
    mainViewMedia.layer.borderColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;// [UIColor grayColor].CGColor;
    mainViewMedia.layer.borderWidth = 3.0f;
    
    [mainViewNoMediaContentView.layer setCornerRadius:15.0];
    //mainViewNoMediaContentView.layer.borderColor = [UIColor grayColor].CGColor;
    //mainViewNoMediaContentView.layer.borderWidth = 1.0f;
    
    [mainViewMediaContentView.layer setCornerRadius:15.0];
    //mainViewMediaContentView.layer.borderColor = [UIColor grayColor].CGColor;
    //mainViewMediaContentView.layer.borderWidth = 1.0f;
    
    popOverWebViewMedia.scrollView.bounces = NO;
    popOverWebViewNoMedia.scrollView.bounces = NO;
    
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
    // if ([text rangeOfString:@"<html>"].location == NSNotFound)
    text = [NSString stringWithFormat:kPopOverHtmlTemplate, text];
    [popOverWebView loadHTMLString:text baseURL:nil];
    
    if(mediaId != 0) {
        [ARISMoviePlayer.view removeFromSuperview];
        [imageView removeFromSuperview];
        if([media.type isEqualToString: kMediaTypeVideo]){
            //ARISMoviePlayer.view.frame = mediaView.frame;
            [mediaView insertSubview: ARISMoviePlayer.view belowSubview:loadingIndicator];
            [self playAudioOrVideoFromMedia:media];
        }
        else if([media.type isEqualToString: kMediaTypeAudio]){
            //ARISMoviePlayer.view.frame = mediaView.frame;
            [mediaView insertSubview: ARISMoviePlayer.view belowSubview:loadingIndicator];
            [self playAudioOrVideoFromMedia:media];
        }
        else if([media.type isEqualToString: kMediaTypeImage]){
            //imageView.frame = mediaView.frame;
            [imageView loadImageFromMedia:media];
            [mediaView addSubview: imageView];
            loadingIndicator.hidden = YES;
        }
        [ARISMoviePlayer.view setNeedsDisplay];
        [imageView setNeedsDisplay];
        [mediaView setNeedsDisplay];
    }
}

#pragma mark Audio and Video
- (void) playAudioOrVideoFromMedia:(Media*)media {
    
    if(media.image != nil && [media.type isEqualToString: kMediaTypeAudio]){
        NSLog(@"PopOver: Playing through AVAudioPlayer");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        NSError* err;
        player = [[AVAudioPlayer alloc] initWithData: media.image error:&err];
        [player setDelegate: self];
        
        if( err )NSLog(@"PopOver: Playing Audio: Failed with reason: %@", [err localizedDescription]);
        else [player play];
        
    }
    else{
        NSLog(@"PopOver: Playing through MPMoviePlayerController");
        ARISMoviePlayer.moviePlayer.shouldAutoplay = YES;
        ARISMoviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [ARISMoviePlayer.moviePlayer setContentURL: [NSURL URLWithString:media.url]];
        [ARISMoviePlayer.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [ARISMoviePlayer.moviePlayer setFullscreen:NO];
        [ARISMoviePlayer.moviePlayer prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:ARISMoviePlayer.moviePlayer];

        loadingIndicator.hidden = NO;
        loadingIndicator.hidesWhenStopped = YES;
        [loadingIndicator startAnimating];
    }
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
        [ARISMoviePlayer.moviePlayer play];
        loadingIndicator.hidden = YES;
    }
}

#pragma mark audioPlayerDone

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player successfully: (BOOL) flag {
    NSLog(@"PopOver: Audio is done playing");
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}


- (IBAction)continuePressed:(id)sender {
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
