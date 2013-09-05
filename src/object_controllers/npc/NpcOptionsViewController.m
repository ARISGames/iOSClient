//
//  NpcOptionsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "NpcOptionsViewController.h"
#import "NpcScriptOption.h"
#import "ARISMediaView.h"
#import "ARISCollapseView.h"
#import "ARISWebView.h"
#import "AppModel.h"
#import "AppServices.h"
#import "UIColor+ARISColors.h"
#import "StateControllerProtocol.h"

@interface NpcOptionsViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate, ARISWebViewDelegate, UIWebViewDelegate, StateControllerProtocol>
{
    ARISMediaView *mediaView;
    
    ARISCollapseView *optionsCollapseView;
    UIScrollView *optionsScrollView;
    UIActivityIndicatorView *loadingIndicator;
    
	NSArray *optionList;
    
    NSString *playerTitle;
    NSString *currentLeaveConversationTitle;
    BOOL currentlyHidingLeaveConversationButton;
    
    int textBoxSizeState;
    
    id<NpcOptionsViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) ARISMediaView *mediaView;
@property (nonatomic, strong) ARISCollapseView *optionsCollapseView;
@property (nonatomic, strong) UIScrollView *optionsScrollView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSArray *optionList;
    
@property (nonatomic, strong) NSString *playerTitle;
@property (nonatomic, strong) NSString *currentLeaveConversationTitle;
@property (nonatomic, assign) BOOL currentlyHidingLeaveConversationButton;

@end

@implementation NpcOptionsViewController

@synthesize mediaView;
@synthesize optionsCollapseView;
@synthesize optionsScrollView;
@synthesize loadingIndicator;
@synthesize optionList;
@synthesize playerTitle;
@synthesize currentLeaveConversationTitle;
@synthesize currentlyHidingLeaveConversationButton;

- (id) initWithFrame:(CGRect)f delegate:(id<NpcOptionsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        playerTitle = NSLocalizedString(@"DialogPlayerName",@"");
        currentLeaveConversationTitle = NSLocalizedString(@"DialogEnd",@"");
        currentlyHidingLeaveConversationButton = NO;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optionsReceivedFromNotification:) name:@"ConversationOptionsReady" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
     
    self.view.bounds = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    self.view.backgroundColor = [UIColor ARISColorContentBackdrop];
    
    Media *pcMedia = 0;
    if     ([AppModel sharedAppModel].currentGame.pcMediaId != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId ofType:nil];
    else if([AppModel sharedAppModel].player.playerMediaId  != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:nil];
    
    if(pcMedia) self.mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds media:pcMedia                                    mode:ARISMediaDisplayModeAspectFill delegate:self];
    else        self.mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] mode:ARISMediaDisplayModeAspectFill delegate:self];
    [self.mediaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToOptions:)]];
    
    self.optionsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 128)];
    self.optionsScrollView.userInteractionEnabled = YES;
    self.optionsScrollView.opaque = NO;
    self.optionsScrollView.scrollEnabled = YES;
    self.optionsScrollView.bounces = NO;
    
    self.optionsCollapseView = [[ARISCollapseView alloc] initWithView:self.optionsScrollView frame:CGRectMake(0, self.view.bounds.size.height-128, self.view.bounds.size.width, 128) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];
    
    [self.view addSubview:self.mediaView];
    [self.view addSubview:self.optionsCollapseView];
}

- (void) passTapToOptions:(UITapGestureRecognizer *)r
{
    [self.optionsCollapseView handleTapped:r];
}

- (void) loadOptionsForNpc:(Npc *)n afterViewingOption:(NpcScriptOption *)o
{
    [delegate optionsRequestsTitle:self.playerTitle];
    [[AppServices sharedAppServices] fetchNpcConversations:n.npcId afterViewingNode:o.nodeId];
    [self showWaitingIndicatorForPlayerOptions];
}

- (void) optionsReceivedFromNotification:(NSNotification*)notification
{
    [self dismissWaitingIndicatorForPlayerOptions];
	[self showPlayerOptions:(NSArray*)[notification object]];
}

- (void) showPlayerOptions:(NSArray *)options
{
    while([[self.optionsScrollView subviews] count] > 0)
        [[[self.optionsScrollView subviews] objectAtIndex:0] removeFromSuperview];
    
    self.optionList = [options sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"hasViewed" ascending:YES]]];
    UIView *cell;
    ARISWebView * text;
    UIImageView *arrow;
    CGRect cellFrame;
    CGRect textFrame;
    for(int i = 0; i < [self.optionList count]; i++)
    {
        cellFrame = CGRectMake(0, 43*i, self.view.bounds.size.width, 43);
        cell = [[UIView alloc] initWithFrame:cellFrame];
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionSelected:)]];
        cell.tag = i;
        
        textFrame = cellFrame;
        textFrame.origin.y = 0;
        textFrame.size.width -= 30;
        text = [[ARISWebView alloc] initWithFrame:textFrame delegate:self];
        text.userInteractionEnabled = NO;
        text.scrollView.scrollEnabled = NO;
        text.scrollView.bounces = NO;
        text.backgroundColor = [UIColor clearColor];
        text.opaque = NO;
        NpcScriptOption *option = [optionList objectAtIndex:i];
        
        if(!option.hasViewed)
            [text loadHTMLString:[NSString stringWithFormat:[UIColor ARISHtmlTemplate], option.optionText] baseURL:nil];
        else
            [text loadHTMLString:[NSString stringWithFormat:[UIColor ARISHtmlTemplate], [NSString stringWithFormat:@"<div style=\"color:#555555;\">%@</div>",option.optionText]] baseURL:nil];
        
        arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
        arrow.frame = CGRectMake(textFrame.size.width, 10, 19, 19);
    
        [cell addSubview:text];
        [cell addSubview:arrow];
        [self.optionsScrollView addSubview:cell];
    }
    
    if(!self.currentlyHidingLeaveConversationButton)
    {
        cellFrame = CGRectMake(0, 43*[self.optionList count], self.view.bounds.size.width, 43);
        cell = [[UIView alloc] initWithFrame:cellFrame];
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionSelected:)]];
        
        textFrame = cellFrame;
        textFrame.origin.y = 0;
        textFrame.size.width -= 30;
        text = [[ARISWebView alloc] initWithFrame:textFrame delegate:self];
        text.userInteractionEnabled = NO;
        text.scrollView.scrollEnabled = NO;
        text.scrollView.bounces = NO;
        text.backgroundColor = [UIColor clearColor];
        text.opaque = NO;
        cell.tag = -1;
        [text loadHTMLString:[NSString stringWithFormat:[UIColor ARISHtmlTemplate], self.currentLeaveConversationTitle] baseURL:nil];
        
        arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
        arrow.frame = CGRectMake(textFrame.size.width, 10, 19, 19);
        
        [cell addSubview:text];
        [cell addSubview:arrow];
        
        [self.optionsScrollView addSubview:cell];
    }
    
    cellFrame = CGRectMake(0, 43*([self.optionList count]+(!self.currentlyHidingLeaveConversationButton)), self.view.bounds.size.width, 40);
    cell = [[UIView alloc] initWithFrame:cellFrame];
    
    textFrame = cellFrame;
    textFrame.origin.y = 0;
    text = [[ARISWebView alloc] initWithFrame:textFrame delegate:self];
    text.delegate = self;
    text.userInteractionEnabled = YES; //to disallow clicks percolating through
    text.scrollView.scrollEnabled = NO;
    text.scrollView.bounces = NO;
    text.backgroundColor = [UIColor clearColor];
    text.opaque = NO;
    [text loadHTMLString:[NSString stringWithFormat:[UIColor ARISHtmlTemplate], @"<div style=\"color:#BBBBBB; font-size:14px; text-align:center;\">(Make a Selection)</div>"] baseURL:nil];
    
    [cell addSubview:text];
    [self.optionsScrollView addSubview:cell];
    
    CGFloat newHeight = 43*[self.optionList count]+(43*(1+(!self.currentlyHidingLeaveConversationButton)));
    self.optionsScrollView.frame = CGRectMake(0, 0, self.optionsScrollView.frame.size.width, newHeight);
    self.optionsScrollView.contentSize = CGSizeMake(self.optionsScrollView.frame.size.width, newHeight);
    [self.optionsCollapseView setOpenFrameHeight:newHeight+10];
}

- (void) showWaitingIndicatorForPlayerOptions
{
    if(!self.loadingIndicator)
    {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.loadingIndicator.center = self.optionsScrollView.center;
    }
    self.optionsScrollView.hidden = YES;
    [self.optionsScrollView addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
}

- (void) dismissWaitingIndicatorForPlayerOptions
{
    [self.loadingIndicator removeFromSuperview];
	[self.loadingIndicator stopAnimating];
    self.optionsScrollView.hidden = NO;
}

- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv
{
    
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    float newOffset = 0.0;
    for(int i = 0; i < [[self.optionsScrollView subviews] count]-1; i++)
    {
        CGRect superFrame = ((UIView *)[[self.optionsScrollView subviews] objectAtIndex:i]).frame;
        superFrame.origin.y += newOffset;
        ((UIView *)[[self.optionsScrollView subviews] objectAtIndex:i]).frame = superFrame;
        if([[self.optionsScrollView subviews] objectAtIndex:i] == [webView superview])
        {
            newOffset = newHeight - webView.superview.frame.size.height;
            webView.frame             = CGRectMake(0,                               0,          webView.frame.size.width,newHeight);
            [webView superview].frame = CGRectMake(0,webView.superview.frame.origin.y,webView.superview.frame.size.width,newHeight);
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, newHeight, webView.superview.frame.size.width, 1)];
            line.backgroundColor = [UIColor ARISColorLightGray];
            [[webView superview] addSubview:line];
        }
    }
    
    UIView *masCell = [[self.optionsScrollView subviews] objectAtIndex:[self.optionsScrollView.subviews count]-1];
    masCell.frame = CGRectMake(masCell.frame.origin.x, masCell.frame.origin.y+newOffset, masCell.frame.size.width, masCell.frame.size.height);
    
    CGRect newFrame = self.optionsScrollView.frame;
    newFrame.size.height += newOffset;
    self.optionsScrollView.frame = newFrame;
    self.optionsScrollView.contentSize = CGSizeMake(newFrame.size.width, newFrame.size.height);
    [self.optionsCollapseView setOpenFrameHeight:self.optionsScrollView.frame.size.height+10];
}

- (void) optionSelected:(UITapGestureRecognizer *)r
{
	if(r.view.tag == -1)
        [delegate leaveConversationRequested];
    else
    {
        NpcScriptOption *selectedOption = [optionList objectAtIndex:r.view.tag];
        selectedOption.scriptText = [[AppModel sharedAppModel] nodeForNodeId:selectedOption.nodeId].text;
        [delegate optionChosen:selectedOption];
    }
}

- (void) toggleNextTextBoxSize
{
    [delegate optionsRequestsTextBoxSize:(textBoxSizeState+1)%3];
}

- (void) toggleTextBoxSize:(int)s
{
    textBoxSizeState = s;
    
    CGRect newFrame;
    switch(textBoxSizeState)
    {
        case 0: newFrame = CGRectMake(0, self.view.bounds.size.height    , 320,                            1); break;
        case 1: newFrame = CGRectMake(0, self.view.bounds.size.height-128, 320,                          128); break;
        case 2: newFrame = CGRectMake(0,                                0, 320, self.view.bounds.size.height); break;
    }
    
	[UIView beginAnimations:@"toggleTextSize" context:nil];
	[UIView setAnimationDuration:0.5];
	self.optionsScrollView.frame  = newFrame;
	[UIView commitAnimations];
}

- (void) setDefaultTitle:(NSString *)t
{
    self.playerTitle = t;
}

- (void) setShowLeaveConversationButton:(BOOL)s
{
    self.currentlyHidingLeaveConversationButton = !s;
}

- (void) setLeaveConversationTitle:(NSString *)t
{
    self.currentLeaveConversationTitle = t;
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    //No need to do anything
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return NO;
}

- (void) displayTab:(NSString *)t
{
}

@end
