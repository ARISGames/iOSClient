//
//  PopOverViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "PopOverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "PopOverContentView.h"
#import "ARISMediaView.h"
#import "ARISWebView.h"
#import "ARISMoviePlayerViewController.h"
#import "AppModel.h"
#import "Media.h"
#import "UIColor+ARISColors.h"

@interface PopOverViewController() <ARISMediaViewDelegate,ARISWebViewDelegate,StateControllerProtocol,UIWebViewDelegate>
{
    UIView *popOverView;
    UIView *contentView;
    ARISWebView *descriptionView;
    ARISMediaView *mediaView;
    UILabel *title;
    UILabel *subtitle;
    UILabel *continueButton;
    
    UIActivityIndicatorView *loadingIndicator;
        
    id<PopOverViewDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UIView *popOverView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ARISWebView *descriptionView;
@property (nonatomic, strong) ARISMediaView *mediaView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UILabel *continueButton;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation PopOverViewController

@synthesize popOverView;
@synthesize contentView;
@synthesize descriptionView;
@synthesize mediaView;
@synthesize title;
@synthesize subtitle;
@synthesize continueButton;

@synthesize loadingIndicator;
        
- (id) initWithDelegate:(id <PopOverViewDelegate>)poDelegate
{
    if(self = [super init])
    {
        delegate = poDelegate;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ARISColorTranslucentBlack];
    
    self.popOverView = [[UIView alloc] initWithFrame:CGRectMake(10,self.view.bounds.size.height/2-214,self.view.bounds.size.width-20,428)];
    self.popOverView.backgroundColor = [UIColor ARISColorTextBackdrop];
    
    self.title    = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.view.bounds.size.width-20,24)];
    self.subtitle = [[UILabel alloc] initWithFrame:CGRectMake(10,34,self.view.bounds.size.width-20,20)];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(10,44+10,self.view.bounds.size.width-20,374)];
    
    self.descriptionView = [[ARISWebView alloc] initWithFrame:CGRectMake(10,10,self.view.bounds.size.width,self.view.bounds.size.height) delegate:self];
}

- (void) setTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int)mediaId
{
    if(!self.view) self.view.hidden = NO; //Just accesses view to force its load
    
    if([text rangeOfString:@"<html>"].location == NSNotFound) text = [NSString stringWithFormat:[UIColor ARISHtmlTemplate], text];
    [self.descriptionView loadHTMLString:text baseURL:nil];
    
    self.mediaView = [[ARISMediaView alloc] initWithFrame:CGRectMake(0,0,mediaView.frame.size.width,mediaView.frame.size.height) media:[[AppModel sharedAppModel] mediaForMediaId:mediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFit delegate:self];
    loadingIndicator.hidden = YES;
}

- (void) continuePressed
{
    [delegate popOverContinueButtonPressed];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self.descriptionView injectHTMLWithARISjs];
}

- (BOOL) webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return ![self.descriptionView handleARISRequestIfApplicable:request];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return NO;
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    
}

- (void) displayTab:(NSString *)t
{
    
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
