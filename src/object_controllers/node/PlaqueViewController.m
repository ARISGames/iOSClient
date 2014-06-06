//
//  PlaqueViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "PlaqueViewController.h"
#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "AppServices.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "ARISWebView.h"
#import "WebPageViewController.h"
#import "WebPage.h"
#import "UIImage+Scale.h"
#import "Plaque.h"

#import <MediaPlayer/MediaPlayer.h>

static NSString * const OPTION_CELL = @"option";

@interface PlaqueViewController() <UIScrollViewDelegate, ARISWebViewDelegate, ARISMediaViewDelegate, StateControllerProtocol>
{
    UIScrollView *scrollView;
    ARISMediaView  *mediaView;
    ARISWebView *webView;
    UIView *continueButton;
    UILabel *continueLbl; 
    UIImageView *arrow;
    UIView *line;
    id <GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end

@implementation PlaqueViewController

- (id) initWithPlaque:(Plaque *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d
{
    if((self = [super init]))
    {
        delegate = d;
    
        plaque = n;
        self.title = plaque.name;
    }
    
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);   
    scrollView.backgroundColor = [ARISTemplate ARISColorContentBackdrop]; 
    scrollView.clipsToBounds = NO; 

    webView = [[ARISWebView alloc] initWithDelegate:self];
    webView.backgroundColor = [UIColor clearColor];
    webView.scrollView.bounces = NO;
    webView.scrollView.scrollEnabled = NO;
    webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
    
    mediaView = [[ARISMediaView alloc] initWithDelegate:self];
    [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight];
    
    continueButton = [[UIView alloc] init];
    continueButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    continueButton.userInteractionEnabled = YES;
    continueButton.accessibilityLabel = @"Continue";
    continueLbl = [[UILabel alloc] init];
    continueLbl.textColor = [ARISTemplate ARISColorText];
    continueLbl.textAlignment = NSTextAlignmentRight;
    continueLbl.text = NSLocalizedString(@"ContinueKey", @"");
    continueLbl.font = [ARISTemplate ARISButtonFont];
    [continueButton addSubview:continueLbl];
    [continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouched)]];
    
    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor ARISColorLightGray];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:continueButton];
    [self.view addSubview:arrow];
    [self.view addSubview:line];
    
    [self loadPlaque];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    scrollView.frame = self.view.bounds;
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height-64-44);  
    
    webView.frame = CGRectMake(0, mediaView.frame.origin.y+mediaView.frame.size.height, self.view.bounds.size.width, webView.frame.size.height > 10 ? webView.frame.size.height : 10);
    
    continueButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    continueLbl.frame = CGRectMake(0,0,self.view.bounds.size.width-30,44);
    arrow.frame = CGRectMake(self.view.bounds.size.width-25, self.view.bounds.size.height-30, 19, 19); 
    line.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 1);
}

- (void) loadPlaque
{
    if(![plaque.desc isEqualToString:@""])
    {
        [scrollView addSubview:webView]; 
        webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);//Needs correct width to calc height
        [webView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], plaque.desc] baseURL:nil]; 
    }
    
    Media *media = [_MODEL_MEDIA_ mediaForId:plaque.media_id];  
    if(media)
    {
        [scrollView addSubview:mediaView];   
        [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
        [mediaView setMedia:media];
    } 
}

- (void) ARISMediaViewFrameUpdated:(ARISMediaView *)amv
{
    if(![plaque.desc isEqualToString:@""])
    {
        webView.frame = CGRectMake(0, mediaView.frame.size.height, self.view.bounds.size.width, webView.frame.size.height);
        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,webView.frame.origin.y+webView.frame.size.height+10);
    }
    else
        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,mediaView.frame.size.height);
}

- (BOOL) ARISMediaViewShouldPlayButtonTouched:(ARISMediaView *)amv
{
    Media *media = [_MODEL_MEDIA_ mediaForId:plaque.media_id];   
    MPMoviePlayerViewController *movieViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
    //error message that is logged after this line is possibly an ios 7 simulator bug...
    [self presentMoviePlayerViewControllerAnimated:movieViewController];
    return NO;
}

- (BOOL) webView:(ARISWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt
{
    [delegate gameObjectViewControllerRequestsDismissal:self];
    WebPage *w = [[WebPage alloc] init];
    w.web_page_id = plaque.plaque_id;
    w.url = [r.URL absoluteString];
    [(id<StateControllerProtocol>)delegate displayGameObject:w fromSource:self];

    return NO;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [webView setFrame:CGRectMake(webView.frame.origin.x,
                                      webView.frame.origin.y,
                                      webView.frame.size.width,
                                      newHeight)];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,webView.frame.origin.y+webView.frame.size.height+10);
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p]; 
}

- (BOOL) displayGameObject:(id)g fromSource:(id)s
{
    return [delegate displayGameObject:g fromSource:s];  
}

- (void) continueButtonTouched
{
	[_SERVICES_ updateServerPlaqueViewed:plaque.plaque_id fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void)dealloc
{
    webView.delegate = nil;
    [webView stopLoading];
    _ARIS_NOTIF_IGNORE_ALL_(self);                            
}

@end
