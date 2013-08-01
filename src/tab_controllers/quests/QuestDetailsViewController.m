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

@interface QuestDetailsViewController() <UIScrollViewDelegate, UIWebViewDelegate, ARISWebViewDelegate, StateControllerProtocol, AsyncMediaImageViewDelegate>
{
    Quest *quest;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *fader;
    IBOutlet UIButton *goButton;
    UIView *mediaSection;
    AsyncMediaImageView *questImageView;
    ARISWebView *webView;
    
    id<QuestDetailsViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}
    
@property (nonatomic, strong) Quest *quest;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *fader;
@property (nonatomic, strong) IBOutlet UIButton *goButton;
@property (nonatomic, strong) UIView *mediaSection;
@property (nonatomic, strong) UIImageView *questImageView;
@property (nonatomic, strong) ARISWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *webViewSpinner;

- (IBAction) goButtonPressed:(id)sender;

@end

@implementation QuestDetailsViewController

NSString *const kQuestDetailsHtmlTemplate =
@"<html>"
@"<head>"
@"	<style type='text/css'><!--"
@"  html,body {margin: 0;padding: 0;}"
@"	body {"
@"		color: #000000;"
@"      text-align: center;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      -webkit-text-size-adjust: none;"
@"	}"
@"  ul,ol { text-align:left; }"
@"	a {color: #000000; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

@synthesize quest;
@synthesize scrollView;
@synthesize fader;
@synthesize goButton;
@synthesize mediaSection;
@synthesize questImageView;
@synthesize webView;
@synthesize webViewSpinner;

- (id) initWithQuest:(Quest *)q delegate:(id<QuestDetailsViewControllerDelegate,StateControllerProtocol>)d;
{
    if(self = [super init])
    {
        self.quest = q;
        delegate = d;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.quest.name;
    self.navigationItem.title = self.quest.name;
    
    self.webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 1) delegate:self]; //Needs width of 320, otherwise "height" is calculated wrong because only 1 character can fit per line
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.quest.mediaId ofType:nil];
    if(media && [media.type isEqualToString:@"PHOTO"] && media.url)
    {
        self.mediaSection = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,20)];
        AsyncMediaImageView *mediaImageView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) andMedia:media andDelegate:self];
        [self.mediaSection addSubview:mediaImageView];
    }
    else if(media && ([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {
        self.mediaSection = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,240)];
        self.webView.frame = CGRectMake(0, self.mediaSection.frame.size.height+10, 320, self.webView.frame.size.height);
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presenter:self preloadNow:NO];
        [self.mediaSection addSubview:mediaButton];
    }
    else
    {
        self.mediaSection = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,20)];
        AsyncMediaImageView *mediaImageView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        [mediaImageView setDelegate:self];
        [mediaImageView updateViewWithNewImage:[UIImage imageNamed:@"item.png"]];
        [self.mediaSection addSubview:mediaImageView];
    }
    
    //Setup the Description Webview
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    if([self.webView respondsToSelector:@selector(scrollView)])
    {
        self.webView.scrollView.bounces = NO;
        self.webView.scrollView.scrollEnabled = NO;
    }
    NSString *text;
    text = self.quest.qdescription;
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
    if([text rangeOfString:@"<html>"].location == NSNotFound) text = [NSString stringWithFormat:kQuestDetailsHtmlTemplate, text];

    
    self.webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
	[self.webView loadHTMLString:text baseURL:nil];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    
    self.webViewSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.webViewSpinner.center = self.webView.center;
    [self.webViewSpinner startAnimating];
    self.webViewSpinner.backgroundColor = [UIColor clearColor];
    [self.webView addSubview:self.webViewSpinner];
    
    //Setup the scrollview
    scrollView.contentSize = CGSizeMake(320, 50);
    if(self.mediaSection) [scrollView addSubview:self.mediaSection];
    [scrollView addSubview:self.webView];
}

- (void) imageFinishedLoading:(AsyncMediaImageView *)image
{
    image.frame = CGRectMake(0, 0, 320, 320/image.image.size.width*image.image.size.height);
    self.mediaSection.frame = image.frame;
    self.webView.frame = CGRectMake(0, self.mediaSection.frame.size.height+10, 320, self.webView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(320,self.webView.frame.origin.y+self.webView.frame.size.height+50);
}

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    [self.webView injectHTMLWithARISjs];
    self.webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
    [self.webView setFrame:CGRectMake(self.webView.frame.origin.x,self.webView.frame.origin.y,self.webView.frame.size.width,newHeight+5)];
    scrollView.contentSize = CGSizeMake(320,self.webView.frame.origin.y+self.webView.frame.size.height+50);
    
    [self.webViewSpinner removeFromSuperview];
}

- (BOOL) webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![self.webView handleARISRequestIfApplicable:request];
    return YES;
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

- (IBAction) goButtonPressed:(id)sender
{
    if([self.quest.goFunction isEqualToString:@"JAVASCRIPT"]) [self.webView hookWithParams:@""];
    else if([self.quest.goFunction isEqualToString:@"NONE"]) return;
    else [self displayTab:self.quest.goFunction];
}

- (void)dealloc
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
