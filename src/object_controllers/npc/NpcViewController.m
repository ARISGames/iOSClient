//
//  NpcViewController.m
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import "NpcViewController.h"
#import "Npc.h"
#import "NpcScriptOption.h"
#import "NpcOptionsViewController.h"
#import "NpcScriptViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "StateControllerProtocol.h"
#import "UIColor+ARISColors.h"

@interface NpcViewController() <NpcOptionsViewControllerDelegate, NpcScriptViewControllerDelegate, AVAudioPlayerDelegate>
{
    Npc *npc;
    NpcScriptOption *option;
    NpcScriptViewController  *scriptViewController;
    NpcOptionsViewController *optionsViewController;
    BOOL closingScriptPlaying;
    BOOL hasAppeared;
    id<GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) Npc *npc;
@property (nonatomic, strong) NpcScriptOption *option;
@property (nonatomic, strong) NpcScriptViewController  *scriptViewController;
@property (nonatomic, strong) NpcOptionsViewController *optionsViewController;

@end

@implementation NpcViewController

@synthesize npc;
@synthesize option;
@synthesize scriptViewController;
@synthesize optionsViewController;

- (id) initWithNpc:(Npc *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d
{
    if((self = [super init]))
    {
        self.npc = n;
        closingScriptPlaying = NO;
        hasAppeared = NO;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorNpcContentBackdrop];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!hasAppeared) [self viewWillAppearFirstTime];
}

- (void) viewWillAppearFirstTime
{
    hasAppeared = YES;
    
    self.optionsViewController = [[NpcOptionsViewController alloc] initWithFrame:self.view.bounds delegate:self];
    self.scriptViewController  = [[NpcScriptViewController alloc] initWithNpc:self.npc frame:self.view.bounds delegate:self];
    
    self.optionsViewController.view.alpha = 0.0;
    self.optionsViewController.view.frame = self.view.bounds;
    self.scriptViewController.view.alpha = 0.0;
    self.scriptViewController.view.frame = self.view.bounds;
    
    if([[self.npc.greeting stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        [self displayOptionsVC];
        [self.optionsViewController loadOptionsForNpc:self.npc afterViewingOption:nil];
    }
    else
    {
        [self displayScriptVC];
        [self.scriptViewController loadScriptOption:[[NpcScriptOption alloc] initWithOptionText:@"" scriptText:self.npc.greeting nodeId:-1 hasViewed:NO]];
    }
}

- (void) optionChosen:(NpcScriptOption *)o
{
    self.option = o;
    [self.scriptViewController loadScriptOption:self.option];
    [self displayScriptVC];
}

- (void) scriptEndedExitToType:(NSString *)type title:(NSString *)title id:(int)typeId
{
    if(closingScriptPlaying && !type) [self dismissSelf];
    
    if(type)
    {
        [self dismissSelf];
        
        if([type isEqualToString:@"tab"])
            [delegate displayTab:title];
        else if([type isEqualToString:@"plaque"])
            [delegate displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:typeId] fromSource:self];
        else if([type isEqualToString:@"webpage"])
            [delegate displayGameObject:[[AppModel sharedAppModel] webPageForWebPageId:typeId] fromSource:self];
        else if([type isEqualToString:@"item"])
            [delegate displayGameObject:[[AppModel sharedAppModel] itemForItemId:typeId] fromSource:self];
        else if([type isEqualToString:@"character"])
            [delegate displayGameObject:[[AppModel sharedAppModel] npcForNpcId:typeId] fromSource:self];
        else if([type isEqualToString:@"panoramic"])
            [delegate displayGameObject:[[AppModel sharedAppModel] panoramicForPanoramicId:typeId] fromSource:self];
    }
    else
    {
        [self.optionsViewController loadOptionsForNpc:self.npc afterViewingOption:self.option];
        [self displayOptionsVC];
    }
}

- (void) displayOptionsVC
{
    [self.view addSubview:self.optionsViewController.view];
    [self.optionsViewController viewWillAppear:YES];
	[UIView beginAnimations:@"movement" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeScriptView)];
	self.optionsViewController.view.alpha = 1.0;
	self.scriptViewController.view.alpha  = 0.0;
	[UIView commitAnimations];
}

- (void) removeScriptView
{
    [self.scriptViewController.view removeFromSuperview];
}

- (void) displayScriptVC
{
    [self.view addSubview:self.scriptViewController.view];
    [self.scriptViewController viewWillAppear:YES];
	[UIView beginAnimations:@"movement" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeOptionsView)];
	self.optionsViewController.view.alpha = 0.0;
	self.scriptViewController.view.alpha  = 1.0;
	[UIView commitAnimations];
}

- (void) removeOptionsView
{
    [self.optionsViewController.view removeFromSuperview];
}

- (void) scriptRequestsTitle:(NSString *)t
{
    self.navigationItem.title = t;
}

- (void) optionsRequestsTitle:(NSString *)t
{
    self.navigationItem.title = t;
}

- (void) scriptRequestsHideLeaveConversation:(BOOL)h
{
    [self.optionsViewController setShowLeaveConversationButton:!h];
}

- (void) scriptRequestsLeaveConversationTitle:(NSString *)t
{
    [self.optionsViewController setLeaveConversationTitle:t];
}

- (void) scriptRequestsOptionsPcTitle:(NSString *)s
{
    [self.optionsViewController setDefaultTitle:s];
}

- (void) scriptRequestsTextBoxSize:(int)s
{
    [self toggleTextBoxSize:s];
}

- (void) optionsRequestsTextBoxSize:(int)s
{
    [self toggleTextBoxSize:s];
}

- (void) toggleNextTextBoxSize
{
    if(self.optionsViewController.view.superview == self.view) [self.optionsViewController toggleNextTextBoxSize];
    if(self.scriptViewController.view.superview  == self.view) [self.scriptViewController  toggleNextTextBoxSize];
}

- (void) hideAdjustTextAreaButton:(BOOL)hide
{
    if(hide) self.navigationItem.rightBarButtonItem = nil;
    else     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"textToggle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleNextTextBoxSize)];
}

- (void) toggleTextBoxSize:(int)s
{
    if(s == 0) [self hideAdjustTextAreaButton:NO];
    
    if(self.optionsViewController.view.superview == self.view) [self.optionsViewController toggleTextBoxSize:s];
    if(self.scriptViewController.view.superview  == self.view) [self.scriptViewController  toggleTextBoxSize:s];
}

- (void) leaveConversationRequested
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [[AppServices sharedAppServices] updateServerNpcViewed:self.npc.npcId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

@end
