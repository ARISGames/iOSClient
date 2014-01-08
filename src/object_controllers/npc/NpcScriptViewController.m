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
#import "Player.h"
#import "AppServices.h"
#import "ARISTemplate.h"

@interface NpcScriptViewController() <ScriptParserDelegate, NpcScriptElementViewDelegate, GameObjectViewControllerDelegate>
{
    Npc *npc;
    
    ScriptParser *parser;
    NpcScriptOption *currentScriptOption;
    Script *currentScript;
    ScriptElement *currentScriptElement;
    
    NpcScriptElementView *npcView;
    NpcScriptElementView *pcView;
    UIView *continueButton;
	
    id<NpcScriptViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) Npc *npc;

@property (nonatomic, strong) ScriptParser *parser;
@property (nonatomic, strong) NpcScriptOption *currentScriptOption;
@property (nonatomic, strong) Script *currentScript;
@property (nonatomic, strong) ScriptElement *currentScriptElement;

@property (nonatomic, strong) NpcScriptElementView *npcView;
@property (nonatomic, strong) NpcScriptElementView *pcView;
@property (nonatomic, strong) UIView *continueButton;

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
        
        delegate = d;
        
        Media *pcMedia;
        if     ([AppModel sharedAppModel].currentGame.pcMediaId != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
        else if([AppModel sharedAppModel].player.playerMediaId  != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId];
        
        if(pcMedia) self.pcView = [[NpcScriptElementView alloc] initWithFrame:self.view.bounds media:pcMedia                                    title:NSLocalizedString(@"DialogPlayerName",@"") delegate:self];
        else        self.pcView = [[NpcScriptElementView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] title:NSLocalizedString(@"DialogPlayerName",@"") delegate:self];
        [self.view addSubview:self.pcView];
        
        Media *npcMedia;
        if(self.npc.mediaId != 0) npcMedia = [[AppModel sharedAppModel] mediaForMediaId:self.npc.mediaId];
        
        if(npcMedia) self.npcView = [[NpcScriptElementView alloc] initWithFrame:self.view.bounds media:npcMedia                                   title:self.npc.name delegate:self];
        else         self.npcView = [[NpcScriptElementView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] title:self.npc.name delegate:self];
        [self.view addSubview:self.npcView];
        
        self.continueButton = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
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
        [self.continueButton addSubview:line];
        [self.continueButton addSubview:continueLabel];
        [self.continueButton addSubview:continueArrow];
        self.continueButton.userInteractionEnabled = YES;
        self.continueButton.backgroundColor = [UIColor clearColor];
        self.continueButton.opaque = NO;
        [self.continueButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(continueButtonTouched)]];
        
        [self.view addSubview:self.continueButton];
        
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
    if(s.defaultPcMediaId)                     [delegate scriptRequestsOptionsPcMedia:[[AppModel sharedAppModel] mediaForMediaId:s.defaultPcMediaId]]; 
    
    self.currentScript = s;
    [self readyNextScriptElementForDisplay];
}

- (void) readyNextScriptElementForDisplay
{
    self.currentScriptElement = [self.currentScript nextScriptElement];
    if(!self.currentScriptElement)
    {
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
    }
    else if([currentScriptElement.type isEqualToString:@"panoramic"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel].currentGame panoramicForPanoramicId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"webpage"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel].currentGame webpageForWebpageId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"node"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel].currentGame nodeForNodeId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    else if([currentScriptElement.type isEqualToString:@"item"])
    {
        [self moveAllOut];
        [((ARISViewController *)delegate).navigationController pushViewController:[[[AppModel sharedAppModel].currentGame itemForItemId:currentScriptElement.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
    }
    self.view.userInteractionEnabled = YES;
}

- (void) scriptElementViewRequestsTitle:(NSString *)t
{
    [delegate scriptRequestsTitle:t];
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [((ARISViewController *)delegate).navigationController popToViewController:((ARISViewController *)delegate) animated:YES];
    [self readyNextScriptElementForDisplay];
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
