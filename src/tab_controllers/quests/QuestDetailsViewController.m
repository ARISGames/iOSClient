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
#import "MediaModel.h"
#import "Quest.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"

@interface QuestDetailsViewController() <UIScrollViewDelegate, ARISWebViewDelegate, StateControllerProtocol, ARISMediaViewDelegate>
{
    UIScrollView *scrollView;
    ARISMediaView  *mediaView;
    ARISWebView *webView;
    UIView *goButton;
    UILabel *goLbl; 
    UIImageView *arrow;
    UIView *line; 
    
    Quest *quest; 
    NSString *mode;
    id<QuestDetailsViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}
    
@end

@implementation QuestDetailsViewController

- (id) initWithQuest:(Quest *)q mode:(NSString *)m delegate:(id<QuestDetailsViewControllerDelegate,StateControllerProtocol>)d
{
    if(self = [super init])
    {
        quest = q;
        mode = m;
        delegate = d;
        self.title = quest.name;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    self.navigationItem.title = quest.name; 
    
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
    
    goButton = [[UIView alloc] init];
    goButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    goButton.userInteractionEnabled = YES;
    goButton.accessibilityLabel = @"BeginQuest";
    goLbl = [[UILabel alloc] init];
    goLbl.textColor = [ARISTemplate ARISColorText];
    goLbl.textAlignment = NSTextAlignmentRight;
    goLbl.text = NSLocalizedString(@"QuestViewBeginQuestKey", @"");
    goLbl.font = [ARISTemplate ARISButtonFont];
    [goButton addSubview:goLbl];
    [goButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goButtonTouched)]];
    
    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor ARISColorLightGray];
    
    [self.view addSubview:scrollView];
    
    [self loadQuest];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    scrollView.frame = self.view.bounds;
    
    goButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    goLbl.frame = CGRectMake(0,0,self.view.bounds.size.width-30,44);
    arrow.frame = CGRectMake(self.view.bounds.size.width-25, self.view.bounds.size.height-30, 19, 19); 
    line.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 1);
}

- (void) loadQuest
{
    [scrollView addSubview:webView]; 
    webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);//Needs correct width to calc height
    [webView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], ([mode isEqualToString:@"ACTIVE"] ? quest.active_desc : quest.complete_desc)] baseURL:nil];  
    
    Media *media = [_MODEL_MEDIA_ mediaForId:([mode isEqualToString:@"ACTIVE"] ? quest.active_media_id : quest.complete_media_id)];
    if(media)
    {
        [scrollView addSubview:mediaView];   
        [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
        [mediaView setMedia:media];
    }  
    
    if(![([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"NONE"])
    {
        scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0); 
        [self.view addSubview:goButton];
        [self.view addSubview:arrow];
        [self.view addSubview:line]; 
    } 
    else
        scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) ARISMediaViewFrameUpdated:(ARISMediaView *)amv
{
    if(![([mode isEqualToString:@"ACTIVE"] ? quest.active_desc : quest.complete_desc) isEqualToString:@""])
    {
        webView.frame = CGRectMake(0, mediaView.frame.size.height, self.view.bounds.size.width, webView.frame.size.height);
        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,webView.frame.origin.y+webView.frame.size.height+10);
    }
    else
        scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,mediaView.frame.size.height);
}

- (BOOL) webView:(ARISWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt
{
    WebPage *w = [_MODEL_WEB_PAGES_ webPageForId:0];
    w.url = [r.URL absoluteString];
    //[(id<StateControllerProtocol>)delegate displayGameObject:w fromSource:self];

    return NO;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    webView.alpha = 1.00;
    
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [webView setFrame:CGRectMake(webView.frame.origin.x,
                                      webView.frame.origin.y,
                                      webView.frame.size.width,
                                      newHeight)];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width,webView.frame.origin.y+webView.frame.size.height+10); 
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    [delegate questDetailsRequestsDismissal];
}

- (void) backButtonTouched
{
    [delegate questDetailsRequestsDismissal];
}

- (void) goButtonTouched
{
    if([([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"JAVASCRIPT"]) [webView hookWithParams:@""];
    else if([([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"NONE"]) return;
    else [self displayTabType:([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function)];
}

//implement statecontrol stuff for webpage, but just delegate any requests
- (BOOL) displayTrigger:(Trigger *)t   { return [delegate displayTrigger:t]; }
- (BOOL) displayTriggerId:(int)t       { return [delegate displayTriggerId:t]; }
- (BOOL) displayInstance:(Instance *)i { return [delegate displayInstance:i]; }
- (BOOL) displayInstanceId:(int)i      { return [delegate displayInstanceId:i]; }
- (BOOL) displayObject:(id)o           { return [delegate displayObject:o]; }
- (BOOL) displayObjectType:(NSString *)type id:(int)type_id { return [delegate displayObjectType:type id:type_id]; }
- (void) displayTab:(Tab *)t           { [delegate displayTab:t]; }
- (void) displayTabId:(int)t           { [delegate displayTabId:t]; }
- (void) displayTabType:(NSString *)t  { [delegate displayTabType:t]; }
- (void) displayScannerWithPrompt:(NSString *)p { [delegate displayScannerWithPrompt:p]; }

- (void) dealloc
{
    webView.delegate = nil;
    [webView stopLoading];
    _ARIS_NOTIF_IGNORE_ALL_(self);                             
}

@end
