//
//  DialogScriptViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "DialogScriptViewController.h"
#import "DialogScriptElementView.h"
#import "ScriptParser.h"
#import "Script.h"
#import "ScriptElement.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "User.h"
#import "AppServices.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DialogScriptViewController() <ScriptParserDelegate, DialogScriptElementViewDelegate>
{
    Dialog *dialog;
    
    ScriptParser *parser;
    Script *currentScript;
    ScriptElement *currentScriptElement;
    
    DialogScriptElementView *npcView;
    DialogScriptElementView *pcView;
    UIView *continueButton;
	
    id<DialogScriptViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation DialogScriptViewController

- (id) initWithDialog:(Dialog *)n frame:(CGRect)f delegate:(id<DialogScriptViewControllerDelegate>)d
{
    if(self = [super init])
    {
        dialog = n;
        parser = [[ScriptParser  alloc] initWithDelegate:self];
        
        delegate = d;
        
        Media *pcMedia;
        if(_MODEL_PLAYER_.media_id  != 0) pcMedia = [_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id];
        
        if(pcMedia) pcView = [[DialogScriptElementView alloc] initWithFrame:self.view.bounds media:pcMedia                                    title:NSLocalizedString(@"DialogPlayerName",@"") delegate:self];
        else        pcView = [[DialogScriptElementView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] title:NSLocalizedString(@"DialogPlayerName",@"") delegate:self];
        [self.view addSubview:pcView];
        
        Media *dialogMedia;
        if(dialogMedia) npcView = [[DialogScriptElementView alloc] initWithFrame:self.view.bounds media:dialogMedia                                   title:dialog.name delegate:self];
        else         npcView = [[DialogScriptElementView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] title:dialog.name delegate:self];
        [self.view addSubview:npcView];
        
        continueButton = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
        UILabel *continueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width-30,44)]; //frame is set later
        continueLabel.textAlignment = NSTextAlignmentRight;
        continueLabel.font = [ARISTemplate ARISButtonFont];
        continueLabel.text = NSLocalizedString(@"ContinueKey",@"");
        continueLabel.textColor = [ARISTemplate ARISColorText];
        continueLabel.accessibilityLabel = @"Continue";
        UIImageView *continueArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
        continueArrow.frame = CGRectMake(self.view.bounds.size.width-25,13,19,19);
        continueArrow.accessibilityLabel = @"Continue";
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,1)];
        line.backgroundColor = [UIColor ARISColorLightGray];
        [continueButton addSubview:line];
        [continueButton addSubview:continueLabel];
        [continueButton addSubview:continueArrow];
        continueButton.userInteractionEnabled = YES;
        continueButton.backgroundColor = [UIColor clearColor];
        continueButton.opaque = NO;
        [continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouched)]];
        
        [self.view addSubview:continueButton];
        
        [self movePcIn];
        
        
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
}

/*
- (void) loadScriptOption:(DialogScriptOption *)o
{
    currentScriptOption = o;
    [parser parseText:o.scriptText];
}
 */

- (void) scriptDidFinishParsing:(Script *)s
{
    //Send global dialog change requests to delegate (properties on dialog tag- would make more sense if they were on the dialog level, but whatevs)
    if(s.hideLeaveConversationButtonSpecified) [delegate scriptRequestsHideLeaveConversation:s.hideLeaveConversationButton];
    if(s.leaveConversationButtonTitle)         [delegate scriptRequestsLeaveConversationTitle:s.leaveConversationButtonTitle];
    if(s.defaultPcTitle)                       [delegate scriptRequestsOptionsPcTitle:s.defaultPcTitle];
    if(s.defaultPcMediaId)                     [delegate scriptRequestsOptionsPcMedia:[_MODEL_MEDIA_ mediaForId:s.defaultPcMediaId]]; 
    
    currentScript = s;
    [self readyNextScriptElementForDisplay];
}

- (void) readyNextScriptElementForDisplay
{
    /*
    currentScriptElement = [currentScript nextScriptElement];
    if(!currentScriptElement)
    {
        [self movePcIn];
        [delegate scriptEndedExitToType:currentScript.exitToType title:currentScript.exitToTabTitle id:currentScript.exitToTypeId];
        return;
    }
    
    if([currentScriptElement.type isEqualToString:@"pc"])
    {
        [pcView loadScriptElement:currentScriptElement];
        [self movePcIn];
    }
    else if([currentScriptElement.type isEqualToString:@"npc"])
    {
        [npcView loadScriptElement:currentScriptElement];
        [self moveDialogIn];
    }
    else if([currentScriptElement.type isEqualToString:@"video"])
    {
        [self moveAllOut];
        [self scriptDisplayVideo:currentScriptElement];
    }
    else if([currentScriptElement.type isEqualToString:@"webpage"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[_MODEL_GAME_ webpageForWebpageId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"plaque"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[_MODEL_PLAQUES_ plaqueForId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"item"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[_MODEL_ITEMS_ itemForId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    self.view.userInteractionEnabled = YES;
     */
}

- (void) scriptDisplayVideo:(ScriptElement *)scriptElement
{
    if (scriptElement.typeId != 0) {
        Media *media = [_MODEL_MEDIA_ mediaForId:scriptElement.typeId];
        MPMoviePlayerViewController *movieViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
        //remove the movie player notification so we can override it with our own
        [[NSNotificationCenter defaultCenter] removeObserver:movieViewController name:MPMoviePlayerPlaybackDidFinishNotification object:movieViewController.moviePlayer];
        //register our callback
  _ARIS_NOTIF_LISTEN_(MPMoviePlayerPlaybackDidFinishNotification, self ,@selector(movieFinishedCallback:) ,movieViewController.moviePlayer);
        [((ARISViewController *)delegate).navigationController presentMoviePlayerViewControllerAnimated:movieViewController];
    }
    else{
        //no media to display, just go to the next script
        [self continueButtonTouched];
    }
}

- (void) movieFinishedCallback:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayer = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [((ARISViewController *)delegate).navigationController dismissViewControllerAnimated:NO completion:^{
        [self continueButtonTouched];
    }];
}

- (void) scriptElementViewRequestsTitle:(NSString *)t
{
    [delegate scriptRequestsTitle:t];
}

/*
- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [((ARISViewController *)delegate).navigationController popToViewController:((ARISViewController *)delegate) animated:YES];
    [self readyNextScriptElementForDisplay];
}
 */

- (void) scriptElementViewRequestsHideContinue:(BOOL)h
{
    if(!h)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.1];
        continueButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
        [UIView commitAnimations];
    }
    if(h)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.1];
        continueButton.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44);
        [UIView commitAnimations];
    }
}

- (void) continueButtonTouched
{
    //stop the movie in the npc view if it is playing
    [npcView stopVideoIfPlaying];
    
    self.view.userInteractionEnabled = NO;
    if     (pcView.frame.origin.x == 0)  [pcView  fadeWithCallback:@selector(readyNextScriptElementForDisplay)];
    else if(npcView.frame.origin.x == 0) [npcView fadeWithCallback:@selector(readyNextScriptElementForDisplay)];
    else [self readyNextScriptElementForDisplay];
}

#define pcOffscreenRect  CGRectMake(  pcView.frame.size.width, pcView.frame.origin.y, pcView.frame.size.width, pcView.frame.size.height)
#define npcOffscreenRect CGRectMake(0-npcView.frame.size.width,npcView.frame.origin.y,npcView.frame.size.width,npcView.frame.size.height)
- (void) movePcIn
{
	[self movePcTo:self.view.frame  withAlpha:1.0
		  andDialogTo:npcOffscreenRect withAlpha:0.0];
}

- (void) moveDialogIn
{
	[self movePcTo:pcOffscreenRect withAlpha:0.0
		  andDialogTo:self.view.frame withAlpha:1.0];
}

- (void) moveAllOut
{
	[self movePcTo:pcOffscreenRect  withAlpha:0.0
		  andDialogTo:npcOffscreenRect withAlpha:0.0];
}

- (void) movePcTo:(CGRect)pcRect  withAlpha:(CGFloat)pcAlpha
		 andDialogTo:(CGRect)npcRect withAlpha:(CGFloat)npcAlpha
{
	[UIView beginAnimations:@"movement" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25];
	npcView.frame = npcRect;
	npcView.alpha = npcAlpha;
	pcView.frame = pcRect;
	pcView.alpha = pcAlpha;
	[UIView commitAnimations];
}

@end
