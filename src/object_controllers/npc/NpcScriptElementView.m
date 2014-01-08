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

@interface NpcScriptElementView() <ARISMediaViewDelegate, ARISCollapseViewDelegate, StateControllerProtocol, ARISWebViewDelegate, UIScrollViewDelegate>
{
    ScriptElement *scriptElement;
    
    UIScrollView *mediaSection;
    ARISMediaView *mediaView;
    ARISCollapseView *textSection;
    ARISWebView *textWebView;
    
    NSString *defaultTitle;
    Media *defaultMedia;
    UIImage *defaultImage;
    
    id<NpcScriptElementViewDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) ScriptElement *scriptElement;

@property (nonatomic, strong) UIScrollView *mediaSection;
@property (nonatomic, strong) ARISMediaView *mediaView;
@property (nonatomic, strong) ARISCollapseView *textSection;
@property (nonatomic, strong) ARISWebView *textWebView;


@property (nonatomic, strong) NSString *defaultTitle;
@property (nonatomic, strong) Media *defaultMedia;
@property (nonatomic, strong) UIImage *defaultImage;

@end

@implementation NpcScriptElementView

@synthesize scriptElement;

@synthesize mediaSection;
@synthesize mediaView;
@synthesize textSection;
@synthesize textWebView;

@synthesize defaultTitle;
@synthesize defaultMedia;
@synthesize defaultImage;

- (void) initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.mediaSection = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.mediaSection.contentInset = UIEdgeInsetsMake(64,0,0,0);
    self.mediaSection.contentSize = CGSizeMake(self.bounds.size.width,self.bounds.size.height-64);
    self.mediaSection.backgroundColor = [UIColor clearColor];
    self.mediaSection.opaque = NO;
    [self.mediaSection addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToTextSection:)]];
    
    self.textWebView = [[ARISWebView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width-20, 10) delegate:self];
    self.textWebView.scrollView.bounces = NO;
    self.textWebView.scrollView.scrollEnabled = NO;
    self.textWebView.opaque = NO;
    self.textWebView.backgroundColor = [UIColor clearColor];
    [self.textWebView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToTextSection:)]];
    
    self.textSection = [[ARISCollapseView alloc] initWithContentView:self.textWebView frame:CGRectMake(0, self.bounds.size.height-20, self.bounds.size.width, 20) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];
    
    [self addSubview:self.mediaSection];
    [self.mediaSection addSubview:self.mediaView];
    [self addSubview:self.textSection];
}

- (id) initWithFrame:(CGRect)f media:(Media *)m title:(NSString *)t delegate:(id<NpcScriptElementViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        self.defaultTitle = t;
        self.defaultMedia = m;
        self.mediaView = [[ARISMediaView alloc] initWithFrame:self.bounds media:m mode:ARISMediaDisplayModeTopAlignAspectFitWidth delegate:self];
        [self initialize];
        self.mediaView.backgroundColor = [UIColor clearColor];
        self.mediaSection.opaque = NO;

        delegate = d;
    }
    return self;
}

- (id) initWithFrame:(CGRect)f image:(UIImage *)i title:(NSString *)t delegate:(id<NpcScriptElementViewDelegate>)d;
{
    if(self = [super initWithFrame:f])
    {
        self.defaultTitle = t;
        self.defaultImage = i;
        self.mediaView = [[ARISMediaView alloc] initWithFrame:self.bounds image:i mode:ARISMediaDisplayModeTopAlignAspectFitWidth delegate:self];
        self.mediaView.backgroundColor = [UIColor clearColor];
        self.mediaSection.opaque = NO;
        [self initialize];
        
        delegate = d;
    }
    return self;
}

- (void) passTapToTextSection:(UITapGestureRecognizer *)r
{
    [self.textSection handleTapped:r];
}

- (void) loadScriptElement:(ScriptElement *)s
{
    self.scriptElement = s;
    
    if(self.scriptElement.vibrate) [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) vibrate];
    if(self.scriptElement.title) [delegate scriptElementViewRequestsTitle:self.scriptElement.title];
    else                         [delegate scriptElementViewRequestsTitle:self.defaultTitle];
    
    if(self.scriptElement.mediaId != 0)
    {
        Media *media = [[AppModel sharedAppModel] mediaForMediaId:self.scriptElement.mediaId];
        [self.mediaView setMedia:media];
    }
    else if(self.defaultImage)
        [self.mediaView setImage:self.defaultImage];
    else if(self.defaultMedia)
        [self.mediaView setMedia:self.defaultMedia];
    
    //Try resetting the text view height to 0 each time for proper content height calculation
    CGRect wvFrame = [self.textWebView frame];
    [self.textWebView setFrame:CGRectMake(wvFrame.origin.x, wvFrame.origin.y, wvFrame.size.width, 10)];
    //Load content
    [self.textWebView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], self.scriptElement.text] baseURL:nil];
    
    //PHIL
    /*
    self.mediaSection.frame = CGRectMake(0,0,self.mediaView.frame.size.width,self.mediaView.frame.size.height);
    CGRect oldImageFrame = self.mediaSection.frame;
    CGRect newImageFrame = self.scriptElement.imageRect;
    
    CGRect zoomContainerRect = CGRectMake((int)(-1*newImageFrame.origin.x*oldImageFrame.size.width/newImageFrame.size.width),
                                          (int)(-1*newImageFrame.origin.y*oldImageFrame.size.height/newImageFrame.size.height),
                                          (int)(oldImageFrame.size.width*oldImageFrame.size.width/newImageFrame.size.width),
                                          (int)(oldImageFrame.size.height*oldImageFrame.size.height/newImageFrame.size.height));

    [UIView transitionWithView:self.mediaSection.superview duration:self.scriptElement.zoomTime options:UIViewAnimationCurveLinear|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionLayoutSubviews animations:^
    {
        self.mediaView.frame  = zoomContainerRect;

        //However, apple gets mad when you try to animate a view and subview simultaneously, so instead we overanimate the subview to compensate and comment out the superview's animation
        self.mediaView.frame = CGRectMake(self.mediaSection.frame.origin.x+self.mediaView.frame.origin.x,self.mediaSection.frame.origin.y+self.mediaView.frame.origin.y,self.mediaView.frame.size.width,self.mediaView.frame.size.height);
    }
    completion:nil];
     */
}

- (void) fadeWithCallback:(SEL)s
{
    [UIView beginAnimations:@"dialog" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDidStopSelector:s];
    self.textWebView.alpha  = 0;
    [UIView commitAnimations];
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
	//Size the webView
	CGRect wvFrame = [wv frame];
    CGFloat wvHeight = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    BOOL emptyText = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;"] isEqualToString:@""];
    
    if(wvHeight+54+64 > self.bounds.size.height) [self.textSection setFrameHeight:self.bounds.size.height-64];
    else if(emptyText)                           [self.textSection setFrameHeight:44];
    else                                         [self.textSection setFrameHeight:wvHeight+54];
    [self.textSection setContentFrame:CGRectMake(wvFrame.origin.x,wvFrame.origin.y,wvFrame.size.width,wvHeight)];
	
    //Fade in the WebView
    [UIView beginAnimations:@"dialog" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.25];
    self.textWebView.alpha = 1.0;
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
