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
#import "ARISMediaView.h"
#import "ARISWebView.h"
#import "AppModel.h"
#import "Media.h"
#import "ARISTemplate.h"

@interface PopOverViewController() <ARISMediaViewDelegate,ARISWebViewDelegate,StateControllerProtocol>
{
    UIView *popOverView;
    UIView *contentView;
    ARISWebView *descriptionView;
    ARISMediaView *mediaView;
    UILabel *title;
    UILabel *subtitle;
    UILabel *continueButton;
    UILabel *goButton; 
    NSString *goFunction;
    
    UIActivityIndicatorView *loadingIndicator;
        
    id<PopOverViewDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UIView *popOverView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ARISWebView *descriptionView;
@property (nonatomic, strong) ARISMediaView *mediaView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UILabel *continueButton;
@property (nonatomic, strong) UILabel *goButton;
@property (nonatomic, strong) NSString *goFunction;

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
@synthesize goButton;
@synthesize goFunction;

@synthesize loadingIndicator;
        
- (id) initWithDelegate:(id <PopOverViewDelegate, StateControllerProtocol>)poDelegate
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
    self.view.userInteractionEnabled = YES;
    
    self.popOverView = [[UIView alloc] initWithFrame:CGRectMake(10,self.view.bounds.size.height/2-214,self.view.bounds.size.width-20,428)];
    self.popOverView.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    self.popOverView.layer.cornerRadius = 10;
    self.popOverView.layer.masksToBounds = YES;
    
    self.title    = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.popOverView.bounds.size.width-20,24)];
    self.title.font = [ARISTemplate ARISTitleFont];
    self.title.backgroundColor = [UIColor clearColor];
    self.subtitle = [[UILabel alloc] initWithFrame:CGRectMake(10,34,self.popOverView.bounds.size.width-20,20)];
    self.subtitle.font = [ARISTemplate ARISSubtextFont];
    self.subtitle.backgroundColor = [UIColor clearColor];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0,44+20,self.popOverView.bounds.size.width,320)];
    
    self.continueButton = [[UILabel alloc] initWithFrame:CGRectMake(10, self.popOverView.frame.size.height-44, (self.popOverView.frame.size.width-20)/2, 44)];
    self.continueButton.text = @" < Dismiss";
    self.continueButton.textAlignment = NSTextAlignmentLeft;
    self.continueButton.backgroundColor = [UIColor clearColor];
    self.continueButton.userInteractionEnabled = YES;
    [self.continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouched)]];
    
    self.goButton = [[UILabel alloc] initWithFrame:CGRectMake(self.popOverView.frame.size.width/2, self.popOverView.frame.size.height-44, (self.popOverView.frame.size.width-20)/2, 44)]; 
    self.goButton.text = @"GO! > ";
    self.goButton.textAlignment = NSTextAlignmentRight;
    self.goButton.backgroundColor = [UIColor clearColor];
    self.goButton.userInteractionEnabled = YES;
    [self.goButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goButtonTouched)]]; 
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.popOverView.frame.size.height-44, self.popOverView.frame.size.width, 1)];
    line.backgroundColor = [UIColor ARISColorLightGray];
    
    [self.popOverView addSubview:self.title];
    [self.popOverView addSubview:self.subtitle];
    [self.popOverView addSubview:self.contentView];
    [self.popOverView addSubview:self.continueButton];
    [self.popOverView addSubview:self.goButton]; 
    [self.popOverView addSubview:line];
    [self.view addSubview:self.popOverView];
}

- (void) setTitle:(NSString *)t description:(NSString *)d webViewText:(NSString *)wvt mediaId:(int)m function:(NSString *)f showDismiss:(BOOL)sd
{
    if(!self.view) self.view.hidden = NO; //Just accesses view to force its load
    
    while([self.contentView.subviews count] > 0)
        [[self.contentView.subviews objectAtIndex:0] removeFromSuperview];
    
    self.title.text    = t;
    self.subtitle.text = d;
    
    if(![wvt isEqualToString:@""])
    {
        self.descriptionView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,0,self.contentView.frame.size.width,10) delegate:self];
        self.descriptionView.scrollView.scrollEnabled = NO;
        self.descriptionView.backgroundColor = [UIColor clearColor];
        self.descriptionView.opaque = NO;
        wvt = [NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], wvt];
        [self.descriptionView loadHTMLString:wvt baseURL:nil];
        [self.contentView addSubview:self.descriptionView];
    }
    
    if(m != 0)
    {
        self.mediaView = [[ARISMediaView alloc] initWithFrame:CGRectMake(10,0,self.contentView.frame.size.width-20,20) media:[[AppModel sharedAppModel] mediaForMediaId:m] mode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight delegate:self];
        [self.contentView addSubview:self.mediaView];
    }
    
    self.goFunction = f;
    if([f isEqualToString:@"NONE"])
    {
        self.continueButton.frame = CGRectMake(10, self.popOverView.frame.size.height-44, self.popOverView.frame.size.width-20, 44);
        self.continueButton.textAlignment = NSTextAlignmentRight;
        self.continueButton.text = @"Dismiss > ";
        self.continueButton.accessibilityLabel = @"Dismiss";
        self.goButton.frame = CGRectMake(self.popOverView.frame.size.width/2, self.popOverView.frame.size.height-44, 0, 44);
        self.goButton.text = @"";
    }
    else if(!sd)
    {
        self.continueButton.frame = CGRectMake(10, self.popOverView.frame.size.height-44, 0, 44);
        self.continueButton.text = @"";
        self.goButton.frame = CGRectMake(10, self.popOverView.frame.size.height-44, self.popOverView.frame.size.width-20, 44);
        self.goButton.textAlignment = NSTextAlignmentRight;
        self.goButton.text = @"GO! > "; 
    }
    else
    {
        self.continueButton.frame = CGRectMake(10, self.popOverView.frame.size.height-44, (self.popOverView.frame.size.width-20)/2, 44);
        self.continueButton.textAlignment = NSTextAlignmentLeft; 
        self.continueButton.text = @" < Dismiss"; 
        self.goButton.frame = CGRectMake(self.popOverView.frame.size.width/2, self.popOverView.frame.size.height-44, (self.popOverView.frame.size.width-20)/2, 44); 
        self.continueButton.textAlignment = NSTextAlignmentRight;  
        self.goButton.text = @"GO! > "; 
    }
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    float newHeight = [[self.descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    
    self.descriptionView.frame = CGRectMake(0, self.descriptionView.frame.origin.y, self.contentView.frame.size.width, newHeight);
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    self.descriptionView.frame = CGRectMake(0,amv.frame.size.height+10,self.contentView.frame.size.width,self.descriptionView.frame.size.height);
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return NO;
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p];
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t]; 
}

- (void) continueButtonTouched
{
    [delegate popOverContinueButtonPressed];
}

- (void) goButtonTouched
{
    if([self.goFunction isEqualToString:@"JAVASCRIPT"]) [self.descriptionView hookWithParams:@""];
    else if(![self.goFunction isEqualToString:@"NONE"]) [self displayTab:self.goFunction];
    
    [self continueButtonTouched];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
