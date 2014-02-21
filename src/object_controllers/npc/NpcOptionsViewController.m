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
#import "Player.h"
#import "ARISTemplate.h"
#import "StateControllerProtocol.h"

@interface NpcOptionsViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate, ARISWebViewDelegate, StateControllerProtocol>
{
  ARISMediaView *mediaView;

  ARISCollapseView *optionsCollapseView;
  UIView *optionsView;
  UIActivityIndicatorView *loadingIndicator;

  NSArray *optionList;

  NSString *playerTitle;
  NSString *currentLeaveConversationTitle;
  BOOL currentlyHidingLeaveConversationButton;

  id<NpcOptionsViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) ARISMediaView *mediaView;
@property (nonatomic, strong) ARISCollapseView *optionsCollapseView;
@property (nonatomic, strong) UIView *optionsView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSArray *optionList;

@property (nonatomic, strong) NSString *playerTitle;
@property (nonatomic, strong) NSString *currentLeaveConversationTitle;
@property (nonatomic, assign) BOOL currentlyHidingLeaveConversationButton;

@end

@implementation NpcOptionsViewController

@synthesize mediaView;
@synthesize optionsCollapseView;
@synthesize optionsView;
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
  self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];

  Media *pcMedia = 0;
  if     ([AppModel sharedAppModel].currentGame.pcMediaId != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
  else if([AppModel sharedAppModel].player.playerMediaId  != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId];

  if(pcMedia) self.mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds media:pcMedia                                    mode:ARISMediaDisplayModeAspectFill delegate:self];
  else        self.mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] mode:ARISMediaDisplayModeAspectFill delegate:self];
  [self.mediaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToOptions:)]];

  self.optionsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 128)];
  self.optionsView.userInteractionEnabled = YES;
  self.optionsView.opaque = NO;

  self.optionsCollapseView = [[ARISCollapseView alloc] initWithContentView:self.optionsView frame:CGRectMake(0, self.view.bounds.size.height-128, self.view.bounds.size.width, 128) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];

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
  while([[self.optionsView subviews] count] > 0)
    [[[self.optionsView subviews] objectAtIndex:0] removeFromSuperview];

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
      [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], option.optionText] baseURL:nil];
    else
      [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], [NSString stringWithFormat:@"<div style=\"color:#555555;\">%@</div>",option.optionText]] baseURL:nil];

    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    arrow.frame = CGRectMake(textFrame.size.width, 10, 19, 19);

    [cell addSubview:text];
    [cell addSubview:arrow];
    [self.optionsView addSubview:cell];
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
    [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], self.currentLeaveConversationTitle] baseURL:nil];

    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    arrow.frame = CGRectMake(textFrame.size.width, 10, 19, 19);

    [cell addSubview:text];
    [cell addSubview:arrow];

    [self.optionsView addSubview:cell];
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
  [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], @"<div style=\"color:#BBBBBB; font-size:14px; text-align:center;\">(Make a Selection)</div>"] baseURL:nil];

  [cell addSubview:text];
  [self.optionsView addSubview:cell];

  CGFloat newHeight = 43*[self.optionList count]+(43*(1+(!self.currentlyHidingLeaveConversationButton)));
  [self.optionsCollapseView setContentFrame:CGRectMake(0, 0, self.optionsView.frame.size.width, newHeight)];
  if((newHeight+10) < self.view.bounds.size.height-64)
    [self.optionsCollapseView setFrameHeight:newHeight+10];
  else
    [self.optionsCollapseView setFrameHeight:self.view.bounds.size.height-64];
}

- (void) showWaitingIndicatorForPlayerOptions
{
  if(!self.loadingIndicator)
  {
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = self.optionsView.center;
  }
  self.optionsView.hidden = YES;
  [self.optionsCollapseView addSubview:self.loadingIndicator];
  [self.loadingIndicator startAnimating];
}

- (void) dismissWaitingIndicatorForPlayerOptions
{
  [self.loadingIndicator removeFromSuperview];
  [self.loadingIndicator stopAnimating];
  self.optionsView.hidden = NO;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)webView
{
  float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
  float newOffset = 0.0;
  for(int i = 0; i < [[self.optionsView subviews] count]-1; i++)
  {
    CGRect superFrame = ((UIView *)[[self.optionsView subviews] objectAtIndex:i]).frame;
    superFrame.origin.y += newOffset;
    ((UIView *)[[self.optionsView subviews] objectAtIndex:i]).frame = superFrame;
    if([[self.optionsView subviews] objectAtIndex:i] == [webView superview])
    {
      newOffset = newHeight - webView.superview.frame.size.height;
      webView.frame             = CGRectMake(0,                               0,          webView.frame.size.width,newHeight);
      [webView superview].frame = CGRectMake(0,webView.superview.frame.origin.y,webView.superview.frame.size.width,newHeight);

      UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, newHeight, webView.superview.frame.size.width, 1)];
      line.backgroundColor = [UIColor ARISColorLightGray];
      [[webView superview] addSubview:line];
    }
  }

  UIView *masCell = [[self.optionsView subviews] objectAtIndex:[self.optionsView.subviews count]-1];
  masCell.frame = CGRectMake(masCell.frame.origin.x, masCell.frame.origin.y+newOffset, masCell.frame.size.width, masCell.frame.size.height);

  [self.optionsCollapseView setContentFrameHeight:self.optionsView.frame.size.height+newOffset];
  if(self.optionsView.frame.size.height+newOffset < self.view.bounds.size.height-64)
    [self.optionsCollapseView setFrameHeight:self.optionsView.frame.size.height+10];
  else 
    [self.optionsCollapseView setFrameHeight:self.view.bounds.size.height-64];
}

- (void) optionSelected:(UITapGestureRecognizer *)r
{
  if(r.view.tag == -1)
    [delegate leaveConversationRequested];
  else
  {
    NpcScriptOption *selectedOption = [optionList objectAtIndex:r.view.tag];
    selectedOption.scriptText = [[AppModel sharedAppModel].currentGame nodeForNodeId:selectedOption.nodeId].text;
    [delegate optionChosen:selectedOption];
  }
}

- (void) setDefaultTitle:(NSString *)t
{
  self.playerTitle = t;
}

- (void) setDefaultMedia:(Media *)m
{
  [self.mediaView setMedia:m]; 
}

- (void) setShowLeaveConversationButton:(BOOL)s
{
  self.currentlyHidingLeaveConversationButton = !s;
}

- (void) setLeaveConversationTitle:(NSString *)t
{
  self.currentLeaveConversationTitle = t;
}

- (void) displayTab:(NSString *)t
{
  //nope
}

- (void) displayScannerWithPrompt:(NSString *)p
{
  //nope
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
  return NO;
}



@end
