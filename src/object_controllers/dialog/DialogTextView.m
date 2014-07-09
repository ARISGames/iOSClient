//
//  DialogTextView.m
//  ARIS
//
//  Created by Phil Dougherty on 7/8/14.
//
//

#import "DialogTextView.h"
#import "ARISWebView.h"
#import "DialogScript.h"

@interface DialogTextView() <ARISWebViewDelegate>
{
    NSString *text;
    ARISWebView *textView;
    BOOL webViewLoaded;
    
    NSArray *options;
    NSMutableArray *optionButtons; 
    int optionWebViewsLoaded;
    
    BOOL fetchingOptions; //this is for 'loading' of the actual list of options
    UIActivityIndicatorView *optionsLoadingIndicator;   
    
    id<DialogTextViewDelegate> __unsafe_unretained delegate;
}
@end

@implementation DialogTextView

- (id) initWithDelegate:(id<DialogTextViewDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
        
        textView = [[ARISWebView alloc] initWithDelegate:self];
        textView.frame = CGRectMake(0,0,self.frame.size.width,1);
        webViewLoaded = NO;
        
        options = [[NSArray alloc] init];
        optionButtons = [[NSMutableArray alloc] init]; 
        optionWebViewsLoaded = 0;
        
        optionsLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        fetchingOptions = YES;
    }
    return self;
}

- (void) setFrame:(CGRect)f
{
    BOOL invalidatesWidth = (f.size.width != self.frame.size.width);
    [super setFrame:f]; 
    if(invalidatesWidth) [self invalidateLayout];
}

- (void) invalidateLayout
{
    while(self.subviews.count > 0)
        [self.subviews[0] removeFromSuperview]; 
    [optionButtons removeAllObjects]; 
    
    webViewLoaded = NO;
    optionWebViewsLoaded = 0;
    
    textView.frame = CGRectMake(0,0,self.frame.size.width,1); 
    [textView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], text] baseURL:nil]; 
    
    for(int i = 0; i < options.count; i++)
        [optionButtons addObject:[self buttonForOption:options[i]]];
}

- (UIView *) buttonForOption:(DialogScript *)d
{
    ARISWebView *b = [[ARISWebView alloc] initWithDelegate:self];
    b.frame = CGRectMake(0,0,self.frame.size.width,1);
    [b loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], d.prompt] baseURL:nil];
    
    UIImageView *continueArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    continueArrow.frame = CGRectMake(self.bounds.size.width-25,13,19,19);
    continueArrow.accessibilityLabel = @"Continue";
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width,1)];
    line.backgroundColor = [UIColor ARISColorLightGray];
    [b addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionSelected:)]];
    
    return b;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    if(wv == textView) webViewLoaded = YES;
    else optionWebViewsLoaded++;
    
    CGFloat height = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]; 
    wv.frame = CGRectMake(wv.frame.origin.x, wv.frame.origin.y, wv.frame.size.width, height);
    
    if(webViewLoaded && optionWebViewsLoaded == optionButtons.count)
        [self layoutButtons];
}

- (void) layoutButtons
{
    int h = 0;
    if(![[textView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;"] isEqualToString:@""])
    {
        [self addSubview:textView];
        h = textView.frame.size.height;
    }
    for(int i = 0; i < optionButtons.count; i++)
    {
        UIView *obv = optionButtons[i];
        obv.frame = CGRectMake(obv.frame.origin.x, h, obv.frame.size.width, obv.frame.size.height);
        [self addSubview:obv];
        h += obv.frame.size.height;
    }
    [delegate expandedToSize:CGSizeMake(self.frame.size.width,h)];
}

- (void) loadText:(NSString *)t
{
    webViewLoaded = NO;
    text = t;
    
    [self invalidateLayout];
}

- (void) setOptionsLoading
{
    optionWebViewsLoaded = 0;
    options = @[];
    [optionButtons removeAllObjects];
    fetchingOptions = YES;
    
    [self invalidateLayout]; 
}

- (void) setOptions:(NSArray *)opts
{
    optionWebViewsLoaded = 0;
    options = opts;
    [optionButtons removeAllObjects];
    fetchingOptions = NO; 
    
    [self invalidateLayout];
}

@end
