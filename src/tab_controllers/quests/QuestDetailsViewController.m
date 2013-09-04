//
//  QuestDetailsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import "QuestDetailsViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Quest.h"
#import "AsyncMediaPlayerButton.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"
#import "UIColor+ARISColors.h"

@interface QuestDetailsViewController() <UIScrollViewDelegate, UIWebViewDelegate, ARISWebViewDelegate, StateControllerProtocol, ARISMediaViewDelegate>
{
    Quest *quest;
    ARISWebView *webView;
    
    BOOL hasAppeared;
    
    id<QuestDetailsViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}
    
@property (nonatomic, strong) Quest *quest;
@property (nonatomic, strong) ARISWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *webViewSpinner;

@end

@implementation QuestDetailsViewController

@synthesize quest;
@synthesize webView;
@synthesize webViewSpinner;

- (id) initWithQuest:(Quest *)q delegate:(id<QuestDetailsViewControllerDelegate,StateControllerProtocol>)d;
{
    if(self = [super init])
    {
        self.quest = q;
        delegate = d;
        self.hidesBottomBarWhenPushed = YES;
        
        hasAppeared = NO;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!hasAppeared) [self viewWillAppearFirstTime];
}

- (void) viewWillAppearFirstTime
{
    hasAppeared = YES;
    
    self.view.backgroundColor = [UIColor ARISColorContentBackdrop];
    self.title = self.quest.name;
    self.navigationItem.title = self.quest.name;
    
    CGRect mainFrame = self.view.bounds;
    
    //self.quest.goFunction = @"JAVASCRIPT";
    if(![self.quest.goFunction isEqualToString:@"NONE"])
    {
        mainFrame.size.height -= 44;
        
        UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goButton.frame = CGRectMake(0, mainFrame.size.height, mainFrame.size.width, 44);
        [goButton setBackgroundColor:[UIColor ARISColorTextBackdrop]];
        [goButton setTitleColor:[UIColor ARISColorText] forState:UIControlStateNormal];
        [goButton setTitle:@"GO     " forState:UIControlStateNormal];
        [goButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [goButton addTarget:self action:@selector(goButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *continueArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
        continueArrow.frame = CGRectMake(self.view.bounds.size.width-25, 14, 19, 19);
        [goButton addSubview:continueArrow];
        [self.view addSubview:goButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, mainFrame.size.height, mainFrame.size.width, 1)];
        line.backgroundColor = [UIColor ARISColorLightGray];
        [self.view addSubview:line];
    }
    
    self.webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 1) delegate:self];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.scrollEnabled = NO;
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.quest.mediaId ofType:nil];
    if(media && [media.type isEqualToString:@"PHOTO"] && media.url)
    {
        [self.view addSubview:[[ARISMediaView alloc] initWithFrame:mainFrame media:media mode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight delegate:self]];
    }
    else if(media && ([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {
        [self.view addSubview:[[AsyncMediaPlayerButton alloc] initWithFrame:mainFrame media:media presenter:self preloadNow:NO]];
    }
    
    NSString *text = self.quest.qdescription;
    /*
    @"<script type='text/javascript'>"
    @"var ARIS = {};"
    @"ARIS.hook = function(params) { ARIS.exitToScanner('woohoo');};"
    @"</script>"
    @"<div style=\"padding:10px;\">"
    @"Yo yo yo you're a hunter blah blah hey cool quest do it."
    @"</div>"
    @"<div style=\"width:120px; margin:0px auto;\">"
    @"<img style=\"width:40px; height:40px;\" src=\"http://www.rdheducation.com/wp-content/themes/onlinecourse/images/star_img.png\" />"
    @"<img style=\"width:40px; height:40px;\" src=\"http://www.rdheducation.com/wp-content/themes/onlinecourse/images/star_img.png\" />"
    @"<img style=\"width:40px; height:40px;\" src=\"http://www.rdheducation.com/wp-content/themes/onlinecourse/images/star_img.png\" />"
    @"</div>"
    @"<div style=\"padding:10px; clear:both;\">"
    @"Yo yo yo you're a hunter blah blah hey cool quest do it."
    @"</div>";
     */
    if([text rangeOfString:@"<html>"].location == NSNotFound) text = [NSString stringWithFormat:[UIColor ARISHtmlTemplate], text];

    self.webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
	[self.webView loadHTMLString:text baseURL:nil];
    
    self.webViewSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.webViewSpinner.backgroundColor = [UIColor clearColor];
    self.webViewSpinner.center = self.webView.center;
    [self.webViewSpinner startAnimating];
    [self.webView addSubview:self.webViewSpinner];
    
    if(!media)
    {
        [self.view addSubview:self.webView];
        [self.view sendSubviewToBack:self.webView];//behind fade thing
    }
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
}

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    [self.webView injectHTMLWithARISjs];
    self.webView.alpha = 1.00;
    
    float newHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]+5;
    [self.webView setFrame:CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y,self.webView.frame.size.width,newHeight)];
    
    [self.webViewSpinner removeFromSuperview];
}

- (BOOL) webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![self.webView handleARISRequestIfApplicable:request];
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    //Ignore 'closeMe' requests...
}

- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv
{
    //Ignore refresh requests...
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p];
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return [delegate displayGameObject:g fromSource:s];
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t];
}

/*
- (void) backButtonPressed
{
    [delegate questDetailsRequestsDismissal];
}
*/
 
- (void) goButtonPressed
{
    if([self.quest.goFunction isEqualToString:@"JAVASCRIPT"]) [self.webView hookWithParams:@""];
    else if([self.quest.goFunction isEqualToString:@"NONE"]) return;
    else [self displayTab:self.quest.goFunction];
}

- (void) dealloc
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
