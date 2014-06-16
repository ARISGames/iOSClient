//
//  DialogOptionsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "DialogOptionsViewController.h"
#import "ARISMediaView.h"
#import "ARISCollapseView.h"
#import "ARISWebView.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "AppServices.h"
#import "User.h"
#import "StateControllerProtocol.h"

@interface DialogOptionsViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate, ARISWebViewDelegate, StateControllerProtocol>
{
  ARISMediaView *mediaView;

  ARISCollapseView *optionsCollapseView;
  UIView *optionsView;
  UIActivityIndicatorView *loadingIndicator;

  NSArray *optionList;

  NSString *playerTitle;
  NSString *currentLeaveConversationTitle;
  BOOL currentlyHidingLeaveConversationButton;

  id<DialogOptionsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation DialogOptionsViewController

/*
- (id) initWithFrame:(CGRect)f delegate:(id<DialogOptionsViewControllerDelegate>)d
{
  if(self = [super init])
  {
    delegate = d;
    playerTitle = NSLocalizedString(@"DialogPlayerName",@"");
    currentLeaveConversationTitle = NSLocalizedString(@"DialogEnd",@"");
    currentlyHidingLeaveConversationButton = NO;

  _ARIS_NOTIF_LISTEN_(@"ConversationOptionsReady",self,@selector(optionsReceivedFromNotification:),nil);
  }
  return self;
}

- (void) loadView
{
  [super loadView];

  self.view.bounds = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
  self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];

  Media *pcMedia = 0;
  if(_MODEL_PLAYER_.media_id  != 0) pcMedia = [_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id];

    mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds delegate:self];
    [mediaView setDisplayMode:ARISMediaDisplayModeAspectFill];
    if(pcMedia) [mediaView setMedia:pcMedia];
    else        [mediaView setImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
  [mediaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToOptions:)]];

  optionsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 128)];
  optionsView.userInteractionEnabled = YES;
  optionsView.opaque = NO;

  optionsCollapseView = [[ARISCollapseView alloc] initWithContentView:optionsView frame:CGRectMake(0, self.view.bounds.size.height-128, self.view.bounds.size.width, 128) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];

  [self.view addSubview:mediaView];
  [self.view addSubview:optionsCollapseView];
}

- (void) passTapToOptions:(UITapGestureRecognizer *)r
{
  [optionsCollapseView handleTapped:r];
}

- (void) loadOptionsForDialog:(Dialog *)n afterViewingOption:(DialogScriptOption *)o
{
  [delegate optionsRequestsTitle:playerTitle];
  [self showWaitingIndicatorForPlayerOptions];
}

- (void) optionsReceivedFromNotification:(NSNotification*)notification
{
  [self dismissWaitingIndicatorForPlayerOptions];
  [self showPlayerOptions:(NSArray*)[notification object]];
}

- (void) showPlayerOptions:(NSArray *)options
{
  while([optionsView subviews].count > 0)
    [[[optionsView subviews] objectAtIndex:0] removeFromSuperview];

  optionList = [options sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"hasViewed" ascending:YES]]];
  UIView *cell;
  ARISWebView * text;
  UIImageView *arrow;
  CGRect cellFrame;
  CGRect textFrame;
  for(int i = 0; i < optionList.count; i++)
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
    DialogScriptOption *option = [optionList objectAtIndex:i];

    if(!option.hasViewed)
      [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], option.optionText] baseURL:nil];
    else
      [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], [NSString stringWithFormat:@"<div style=\"color:#555555;\">%@</div>",option.optionText]] baseURL:nil];

    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    arrow.frame = CGRectMake(textFrame.size.width, 10, 19, 19);

    [cell addSubview:text];
    [cell addSubview:arrow];
    [optionsView addSubview:cell];
  }

  if(!currentlyHidingLeaveConversationButton)
  {
    cellFrame = CGRectMake(0, 43*optionList.count, self.view.bounds.size.width, 43);
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
    [text loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], currentLeaveConversationTitle] baseURL:nil];

    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    arrow.frame = CGRectMake(textFrame.size.width, 10, 19, 19);

    [cell addSubview:text];
    [cell addSubview:arrow];

    [optionsView addSubview:cell];
  }

  cellFrame = CGRectMake(0, 43*(optionList.count+(!currentlyHidingLeaveConversationButton)), self.view.bounds.size.width, 40);
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
  [optionsView addSubview:cell];

  CGFloat newHeight = 43*optionList.count+(43*(1+(!currentlyHidingLeaveConversationButton)));
  [optionsCollapseView setContentFrame:CGRectMake(0, 0, optionsView.frame.size.width, newHeight)];
  if((newHeight+10) < self.view.bounds.size.height-64)
    [optionsCollapseView setFrameHeight:newHeight+10];
  else
    [optionsCollapseView setFrameHeight:self.view.bounds.size.height-64];
}

- (void) showWaitingIndicatorForPlayerOptions
{
  if(!loadingIndicator)
  {
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = optionsView.center;
  }
  optionsView.hidden = YES;
  [optionsCollapseView addSubview:loadingIndicator];
  [loadingIndicator startAnimating];
}

- (void) dismissWaitingIndicatorForPlayerOptions
{
  [loadingIndicator removeFromSuperview];
  [loadingIndicator stopAnimating];
  optionsView.hidden = NO;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)webView
{
  float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
  float newOffset = 0.0;
  for(int i = 0; i < [optionsView subviews].count-1; i++)
  {
    CGRect superFrame = ((UIView *)[[optionsView subviews] objectAtIndex:i]).frame;
    superFrame.origin.y += newOffset;
    ((UIView *)[[optionsView subviews] objectAtIndex:i]).frame = superFrame;
    if([[optionsView subviews] objectAtIndex:i] == [webView superview])
    {
      newOffset = newHeight - webView.superview.frame.size.height;
      webView.frame             = CGRectMake(0,                               0,          webView.frame.size.width,newHeight);
      [webView superview].frame = CGRectMake(0,webView.superview.frame.origin.y,webView.superview.frame.size.width,newHeight);

      UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, newHeight, webView.superview.frame.size.width, 1)];
      line.backgroundColor = [UIColor ARISColorLightGray];
      [[webView superview] addSubview:line];
    }
  }

  UIView *masCell = [[optionsView subviews] objectAtIndex:optionsView.subviews.count-1];
  masCell.frame = CGRectMake(masCell.frame.origin.x, masCell.frame.origin.y+newOffset, masCell.frame.size.width, masCell.frame.size.height);

  [optionsCollapseView setContentFrameHeight:optionsView.frame.size.height+newOffset];
  if(optionsView.frame.size.height+newOffset < self.view.bounds.size.height-64)
    [optionsCollapseView setFrameHeight:optionsView.frame.size.height+10];
  else 
    [optionsCollapseView setFrameHeight:self.view.bounds.size.height-64];
}

- (void) optionSelected:(UITapGestureRecognizer *)r
{
  if(r.view.tag == -1)
    [delegate leaveConversationRequested];
  else
  {
    DialogScriptOption *selectedOption = [optionList objectAtIndex:r.view.tag];
    selectedOption.scriptText = [_MODEL_PLAQUES_ plaqueForId:selectedOption.plaque_id].desc;
    [delegate optionChosen:selectedOption];
  }
}

- (void) setDefaultTitle:(NSString *)t
{
  playerTitle = t;
}

- (void) setDefaultMedia:(Media *)m
{
  [mediaView setMedia:m]; 
}

- (void) setShowLeaveConversationButton:(BOOL)s
{
  currentlyHidingLeaveConversationButton = !s;
}

- (void) setLeaveConversationTitle:(NSString *)t
{
  currentLeaveConversationTitle = t;
}

- (void) displayTab:(NSString *)t
{
  //nope
}

- (void) displayScannerWithPrompt:(NSString *)p
{
  //nope
}

- (BOOL) displayGameObject:(id)g fromSource:(id)s
{
  return NO;
}

 */
@end
