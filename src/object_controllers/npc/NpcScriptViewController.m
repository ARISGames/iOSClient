//
//  NpcScriptViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "NpcScriptViewController.h"
#import "NpcScriptElementView.h"
#import "NpcScriptOption.h"
#import "ScriptParser.h"
#import "Script.h"
#import "ScriptElement.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "AppServices.h"
#import "ARISMoviePlayerViewController.h"
#import "UIColor+ARISColors.h"

@interface NpcScriptViewController() <ScriptParserDelegate, NPcScriptElementViewDelegate, GameObjectViewControllerDelegate>
{
    Npc *npc;
    
    ScriptParser *parser;
    NpcScriptOption *currentScriptOption;
    Script *currentScript;
    ScriptElement *currentScriptElement;
    
    NpcScriptElementView *npcView;
    NpcScriptElementView *pcView;
    UILabel *continueButton;
    
    int textBoxSizeState;
    CGRect viewFrame;
	
    id<NpcScriptViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) Npc *npc;

@property (nonatomic, strong) ScriptParser *parser;
@property (nonatomic, strong) NpcScriptOption *currentScriptOption;
@property (nonatomic, strong) Script *currentScript;
@property (nonatomic, strong) ScriptElement *currentScriptElement;

@property (nonatomic, strong) NpcScriptElementView *npcView;
@property (nonatomic, strong) NpcScriptElementView *pcView;
@property (nonatomic, strong) UILabel *continueButton;

@end

@implementation NpcScriptViewController

@synthesize npc;
@synthesize parser;
@synthesize currentScriptOption;
@synthesize currentScript;
@synthesize currentScriptElement;
@synthesize npcView;
@synthesize pcView;
@synthesize continueButton;

- (id) initWithNpc:(Npc *)n frame:(CGRect)f delegate:(id<NpcScriptViewControllerDelegate>)d
{
    if(self = [super init])
    {
        self.npc = n;
        self.parser = [[ScriptParser  alloc] initWithDelegate:self];
        
        viewFrame = f; //ugh
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    self.view.frame = viewFrame;
    self.view.bounds = CGRectMake(0,0,viewFrame.size.width,viewFrame.size.height);
    self.view.backgroundColor = [UIColor ARISColorContentBackdrop];
    
    CGRect scriptElementFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    
    Media *pcMedia;
    if     ([AppModel sharedAppModel].currentGame.pcMediaId != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId ofType:nil];
    else if([AppModel sharedAppModel].player.playerMediaId  != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:nil];
    if(pcMedia) self.pcView = [[NpcScriptElementView alloc] initWithFrame:scriptElementFrame media:pcMedia                                    title:NSLocalizedString(@"DialogPlayerName",@"") delegate:self];
    else        self.pcView = [[NpcScriptElementView alloc] initWithFrame:scriptElementFrame image:[UIImage imageNamed:@"DefaultPCImage.png"] title:NSLocalizedString(@"DialogPlayerName",@"") delegate:self];
    [self.view addSubview:self.pcView];
    
    Media *npcMedia;
    if(self.npc.mediaId != 0) npcMedia = [[AppModel sharedAppModel] mediaForMediaId:self.npc.mediaId ofType:nil];
    if(npcMedia) self.npcView = [[NpcScriptElementView alloc] initWithFrame:scriptElementFrame media:npcMedia                                   title:self.npc.name delegate:self];
    else         self.npcView = [[NpcScriptElementView alloc] initWithFrame:scriptElementFrame image:[UIImage imageNamed:@"DefaultPCImage.png"] title:self.npc.name delegate:self];
    [self.view addSubview:self.npcView];
    
    self.continueButton = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    self.continueButton.textAlignment = NSTextAlignmentRight;
    self.continueButton.text = @"Continue > ";
    self.continueButton.userInteractionEnabled = YES;
    self.continueButton.backgroundColor = [UIColor clearColor];
    self.continueButton.opaque = NO;
    [self.continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouched)]];
    [self.view addSubview:continueButton];
    
    [self movePcIn];
}

- (void) loadScriptOption:(NpcScriptOption *)o
{
    self.currentScriptOption = o;
    [self.parser parseText:o.scriptText];
}

- (void) scriptDidFinishParsing:(Script *)s
{
    //Send global npc change requests to delegate (properties on dialog tag- would make more sense if they were on the npc level, but whatevs)
    if(s.hideLeaveConversationButtonSpecified) [delegate scriptRequestsHideLeaveConversation:s.hideLeaveConversationButton];
    if(s.leaveConversationButtonTitle)         [delegate scriptRequestsLeaveConversationTitle:s.leaveConversationButtonTitle];
    if(s.defaultPcTitle)                       [delegate scriptRequestsOptionsPcTitle:s.defaultPcTitle];
    if(s.adjustTextArea)                       [self adjustTextArea:s.adjustTextArea];
    
    self.currentScript = s;
    [self readyNextScriptElementForDisplay];
}

- (void) play
{
    Media *media = [[AppModel sharedAppModel] mediaForMediaId:currentScriptElement.typeId ofType:@"VIDEO"];
    ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
    mMoviePlayer.moviePlayer.shouldAutoplay = YES;
    [mMoviePlayer.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}
    
- (void) readyNextScriptElementForDisplay
{
    self.currentScriptElement = [self.currentScript nextScriptElement];
    if(!self.currentScriptElement)
    {
        [[AppServices sharedAppServices] updateServerNodeViewed:self.currentScriptOption.nodeId fromLocation:0];
        [self movePcIn];
        [delegate scriptEndedExitToType:self.currentScript.exitToType title:self.currentScript.exitToTabTitle id:self.currentScript.exitToTypeId];
        return;
    }
    
    if([self.currentScriptElement.type isEqualToString:@"pc"])
    {
        [self.pcView loadScriptElement:self.currentScriptElement];
        [self movePcIn];
    }
    else if([self.currentScriptElement.type isEqualToString:@"npc"])
    {
        [self.npcView loadScriptElement:self.currentScriptElement];
        [self moveNpcIn];
    }
    else if([currentScriptElement.type isEqualToString:@"video"])
    {
        [self moveAllOut];
        [self performSelector:@selector(play) withObject:nil afterDelay:1.0];
    }
    else if([currentScriptElement.type isEqualToString:@"panoramic"])
    {
        [self moveAllOut];
        [((UIViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel] panoramicForPanoramicId:currentScriptElement.typeId] viewControllerForDelegate:self viewFrame:self.view.bounds fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"webpage"])
    {
        [self moveAllOut];
        [((UIViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel] webPageForWebPageId:currentScriptElement.typeId] viewControllerForDelegate:self viewFrame:self.view.bounds fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"node"])
    {
        [self moveAllOut];
        [((UIViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel] nodeForNodeId:currentScriptElement.typeId] viewControllerForDelegate:self viewFrame:self.view.bounds fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"item"])
    {
        [self moveAllOut];
        [((UIViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel] itemForItemId:currentScriptElement.typeId] viewControllerForDelegate:self viewFrame:self.view.bounds fromSource:self] animated:YES];
    }
    self.view.userInteractionEnabled = YES;
}

- (void) scriptElementViewRequestsTitle:(NSString *)t
{
    [delegate scriptRequestsTitle:t];
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [((UIViewController *)delegate).navigationController popToViewController:((UIViewController *)delegate) animated:YES];
    [self readyNextScriptElementForDisplay];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioPlayer successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}

- (void) scriptElementViewRequestsTextBoxArea:(NSString *)a
{
    [self adjustTextArea:a];
}

- (void) scriptElementViewRequestsHideTextAdjust:(BOOL)h
{
    //tell delegate to hide/show textadjust button
}

- (void) scriptElementViewRequestsHideContinue:(BOOL)h
{
    if(!h)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.1];
        self.continueButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
        [UIView commitAnimations];
    }
    if(h)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.1];
        self.continueButton.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44);
        [UIView commitAnimations];
    }
}

- (void) adjustTextArea:(NSString *)area
{
    if([area isEqualToString:@"hidden"])    [self toggleTextBoxSize:0];
    else if([area isEqualToString:@"half"]) [self toggleTextBoxSize:1];
    else if([area isEqualToString:@"full"]) [self toggleTextBoxSize:2];
}

- (void) toggleNextTextBoxSize
{
    [delegate scriptRequestsTextBoxSize:(textBoxSizeState+1)%3];
}

- (void) toggleTextBoxSize:(int)s
{
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
    [delegate scriptRequestsTextBoxSize:s];
    [self.pcView  toggleTextBoxSize:s];
    [self.npcView toggleTextBoxSize:s];
}

- (void) continueButtonTouched
{
    self.view.userInteractionEnabled = NO;
    if     (self.pcView.frame.origin.x == 0)  [self.pcView  fadeWithCallback:@selector(readyNextScriptElementForDisplay)];
    else if(self.npcView.frame.origin.x == 0) [self.npcView fadeWithCallback:@selector(readyNextScriptElementForDisplay)];
    else [self readyNextScriptElementForDisplay];
}

#define pcOffscreenRect  CGRectMake(  self.pcView.frame.size.width, self.pcView.frame.origin.y, self.pcView.frame.size.width, self.pcView.frame.size.height)
#define npcOffscreenRect CGRectMake(0-self.npcView.frame.size.width,self.npcView.frame.origin.y,self.npcView.frame.size.width,self.npcView.frame.size.height)
- (void) movePcIn
{
	[self movePcTo:self.view.frame  withAlpha:1.0
		  andNpcTo:npcOffscreenRect withAlpha:0.0];
}

- (void) moveNpcIn
{
	[self movePcTo:pcOffscreenRect withAlpha:0.0
		  andNpcTo:self.view.frame withAlpha:1.0];
}

- (void) moveAllOut
{
	[self movePcTo:pcOffscreenRect  withAlpha:0.0
		  andNpcTo:npcOffscreenRect withAlpha:0.0];
}

- (void) movePcTo:(CGRect)pcRect  withAlpha:(CGFloat)pcAlpha
		 andNpcTo:(CGRect)npcRect withAlpha:(CGFloat)npcAlpha
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
