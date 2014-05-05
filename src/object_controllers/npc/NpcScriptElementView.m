//
//  NpcScriptElementView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "NpcScriptElementView.h"
#import "ScriptElement.h"
#import "ARISMediaView.h"
#import "ARISWebView.h"
#import "ARISAppDelegate.h"
#import "ARISCollapseView.h"
#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "ARISTemplate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface NpcScriptElementView() <ARISMediaViewDelegate, ARISCollapseViewDelegate, StateControllerProtocol, ARISWebViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate>
{
    ScriptElement *scriptElement;
    
    UIScrollView *mediaSection;
    ARISMediaView *mediaView;
    ARISCollapseView *textSection;
    ARISWebView *textWebView;
    
    NSString *defaultTitle;
    Media *defaultMedia;
    UIImage *defaultImage;
    
    AVAudioPlayer *player;
    UIButton *playAudioButton;
    
    id<NpcScriptElementViewDelegate> __unsafe_unretained delegate;
}

@end

@implementation NpcScriptElementView

- (void) initialize
{
    self.backgroundColor = [UIColor clearColor];
    mediaSection = [[UIScrollView alloc] initWithFrame:self.bounds];
    mediaSection.contentInset = UIEdgeInsetsMake(64,0,0,0);
    mediaSection.contentSize = CGSizeMake(self.bounds.size.width,self.bounds.size.height-64);
    mediaSection.backgroundColor = [UIColor clearColor];
    mediaSection.opaque = NO;
    [mediaSection addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToTextSection:)]];
    
    textWebView = [[ARISWebView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-20, 10) delegate:self];
    textWebView.scrollView.bounces = NO;
    textWebView.scrollView.scrollEnabled = NO;
    textWebView.opaque = NO;
    textWebView.backgroundColor = [UIColor clearColor];
    [textWebView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToTextSection:)]];
    
    textSection = [[ARISCollapseView alloc] initWithContentView:textWebView frame:CGRectMake(0, self.bounds.size.height-20, self.bounds.size.width, 20) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];
    
    UIImage *playImage = [UIImage imageNamed:@"play.png"];
    playAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playAudioButton setImage:playImage forState:UIControlStateNormal];
    playAudioButton.frame = CGRectMake((self.frame.size.width / 2) - (playImage.size.width / 2), (self.frame.size.height / 2) - (playImage.size.height / 2), playImage.size.width, playImage.size.height);
    [playAudioButton addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:mediaSection];
    [mediaSection addSubview:mediaView];
    [self addSubview:textSection];
}

- (id) initWithFrame:(CGRect)f media:(Media *)m title:(NSString *)t delegate:(id<NpcScriptElementViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        defaultTitle = t;
        defaultMedia = m;
        mediaView = [[ARISMediaView alloc] initWithFrame:self.bounds delegate:self];
        [mediaView setDelegate:self];
        [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidth];
        [mediaView setMedia:m];
        [self initialize];
        mediaView.backgroundColor = [UIColor clearColor];
        mediaSection.opaque = NO;

        delegate = d;
    }
    return self;
}

- (id) initWithFrame:(CGRect)f image:(UIImage *)i title:(NSString *)t delegate:(id<NpcScriptElementViewDelegate>)d;
{
    if(self = [super initWithFrame:f])
    {
        defaultTitle = t;
        defaultImage = i;
        mediaView = [[ARISMediaView alloc] initWithFrame:self.bounds delegate:self];
        [mediaView setImage:i];
        [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidth];
        mediaView.backgroundColor = [UIColor clearColor];
        mediaSection.opaque = NO;
        [self initialize];
        
        delegate = d;
    }
    return self;
}

- (void) passTapToTextSection:(UITapGestureRecognizer *)r
{
    [textSection handleTapped:r];
}

- (void) loadScriptElement:(ScriptElement *)s
{
    [playAudioButton removeFromSuperview];
    scriptElement = s;
    Media *media;
    
    if(scriptElement.vibrate) [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) vibrate];
    if(scriptElement.title) [delegate scriptElementViewRequestsTitle:scriptElement.title];
    else                         [delegate scriptElementViewRequestsTitle:defaultTitle];
    
    if(scriptElement.mediaId != 0)
    {
        media = [_MODEL_MEDIA_ mediaForMediaId:scriptElement.mediaId];
        if (![media.type isEqualToString:@"AUDIO"]) {
            [mediaView setMedia:media];
            mediaView.frame = CGRectMake(0, 0, self.frame.size.width, 240);
        }
        else{
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:media.localURL error:nil];
            player.delegate = self;
            [self playAudio];
        }
    }
    else if(defaultImage)
        [mediaView setImage:defaultImage];
    else if(defaultMedia)
        [mediaView setMedia:defaultMedia];
    
    //Try resetting the text view height to 0 each time for proper content height calculation
    CGRect wvFrame = [textWebView frame];
    [textWebView setFrame:CGRectMake(wvFrame.origin.x, wvFrame.origin.y, wvFrame.size.width, 10)];
    //Load content
    [textWebView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], scriptElement.text] baseURL:nil];
    
    //PHIL
    /*
    mediaSection.frame = CGRectMake(0,0,mediaView.frame.size.width,mediaView.frame.size.height);
    CGRect oldImageFrame = mediaSection.frame;
    CGRect newImageFrame = scriptElement.imageRect;
    
    CGRect zoomContainerRect = CGRectMake((int)(-1*newImageFrame.origin.x*oldImageFrame.size.width/newImageFrame.size.width),
                                          (int)(-1*newImageFrame.origin.y*oldImageFrame.size.height/newImageFrame.size.height),
                                          (int)(oldImageFrame.size.width*oldImageFrame.size.width/newImageFrame.size.width),
                                          (int)(oldImageFrame.size.height*oldImageFrame.size.height/newImageFrame.size.height));

    [UIView transitionWithView:mediaSection.superview duration:scriptElement.zoomTime options:UIViewAnimationCurveLinear|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionLayoutSubviews animations:^
    {
        mediaView.frame  = zoomContainerRect;

        //However, apple gets mad when you try to animate a view and subview simultaneously, so instead we overanimate the subview to compensate and comment out the superview's animation
        mediaView.frame = CGRectMake(mediaSection.frame.origin.x+mediaView.frame.origin.x,mediaSection.frame.origin.y+mediaView.frame.origin.y,mediaView.frame.size.width,mediaView.frame.size.height);
    }
    completion:nil];
     */
}

- (void) playAudio
{
    [playAudioButton removeFromSuperview];
    [player play];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self addSubview:playAudioButton];
}

- (void) ARISMediaViewIsReadyToPlay:(ARISMediaView *)amv
{
    [mediaView play];
}


- (void) stopVideoIfPlaying
{
    [mediaView stop];
}

- (void) fadeWithCallback:(SEL)s
{
    [UIView beginAnimations:@"dialog" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDidStopSelector:s];
    textWebView.alpha  = 0;
    [UIView commitAnimations];
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
	//Size the webView
	CGRect wvFrame = [wv frame];
    CGFloat wvHeight = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    BOOL emptyText = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;"] isEqualToString:@""];
    
    if(wvHeight+54+64 > self.bounds.size.height) [textSection setFrameHeight:self.bounds.size.height-64];
    else if(emptyText)                           [textSection setFrameHeight:44];
    else                                         [textSection setFrameHeight:wvHeight+54];
    [textSection setContentFrame:CGRectMake(wvFrame.origin.x,wvFrame.origin.y,wvFrame.size.width,wvHeight)];
	
    //Fade in the WebView
    [UIView beginAnimations:@"dialog" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.25];
    textWebView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) displayTab:(NSString *)t
{
    
}

- (void) collapseView:(ARISCollapseView *)cv wasDragged:(UIPanGestureRecognizer *)r
{
    if(r.state == UIGestureRecognizerStateBegan) 
        [delegate scriptElementViewRequestsHideContinue:YES];
}

- (void) collapseView:(ARISCollapseView *)cv didStartOpen:(BOOL)o
{
    [delegate scriptElementViewRequestsHideContinue:!o];
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return NO;
}

- (void) displayScannerWithPrompt:(NSString *)p
{
}

@end
