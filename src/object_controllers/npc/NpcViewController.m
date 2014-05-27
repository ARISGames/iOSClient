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
#import "ARISTemplate.h"

@interface NpcViewController() <NpcOptionsViewControllerDelegate, NpcScriptViewControllerDelegate, AVAudioPlayerDelegate>
{
    Npc *npc;
    NpcScriptOption *option;
    NpcScriptViewController  *scriptViewController;
    NpcOptionsViewController *optionsViewController;
    
    UIButton *backButton;
    BOOL hideBackButton;
    
    BOOL closingScriptPlaying;
    id<GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) Npc *npc;
@property (nonatomic, strong) NpcScriptOption *option;
@property (nonatomic, strong) NpcScriptViewController  *scriptViewController;
@property (nonatomic, strong) NpcOptionsViewController *optionsViewController;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation NpcViewController

@synthesize npc;
@synthesize option;
@synthesize scriptViewController;
@synthesize optionsViewController;
@synthesize backButton;

- (id) initWithNpc:(Npc *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d
{
    if((self = [super init]))
    {
        self.npc = n;
        closingScriptPlaying = NO;
        delegate = d;
        hideBackButton = NO;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorNpcContentBackdrop];
    
    self.optionsViewController = [[NpcOptionsViewController alloc] initWithFrame:self.view.bounds delegate:self];
    self.optionsViewController.view.alpha = 0.0; 
    self.scriptViewController  = [[NpcScriptViewController alloc] initWithNpc:self.npc frame:self.view.bounds delegate:self]; 
    self.scriptViewController.view.alpha = 0.0;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0, 0, 19, 19);
    [self.backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    self.backButton.accessibilityLabel = @"Back Button";
    [self.backButton addTarget:self action:@selector(leaveConversationRequested) forControlEvents:UIControlEventTouchUpInside]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.optionsViewController.view.frame = self.view.bounds;
    self.scriptViewController.view.frame = self.view.bounds;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = NO;
   	if (hideBackButton) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [self beginNpcInteraction];
}

- (void) viewDidAppearFirstTime:(BOOL)animated
{
    [super viewDidAppearFirstTime:animated];
}

- (void) beginNpcInteraction
{
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
    if(closingScriptPlaying && !type)
    {
        closingScriptPlaying = NO; //reset for the next time the npc is viewed
        [[AppServices sharedAppServices] updateServerNodeViewed:self.option.nodeId fromLocation:0];
        [self dismissSelf];
    }
    
    if(type)
    {
        [[AppServices sharedAppServices] updateServerNodeViewed:self.option.nodeId fromLocation:0];
        [self dismissSelf];
        
        if([type isEqualToString:@"tab"])
            [delegate displayTab:title];
        if([type isEqualToString:@"scanner"])
            [delegate displayScannerWithPrompt:title]; 
        else if([type isEqualToString:@"plaque"])
            [delegate displayGameObject:[[AppModel sharedAppModel].currentGame nodeForNodeId:typeId] fromSource:self];
        else if([type isEqualToString:@"webpage"])
            [delegate displayGameObject:[[AppModel sharedAppModel].currentGame webpageForWebpageId:typeId] fromSource:self];
        else if([type isEqualToString:@"item"])
            [delegate displayGameObject:[[AppModel sharedAppModel].currentGame itemForItemId:typeId] fromSource:self];
        else if([type isEqualToString:@"character"])
            [delegate displayGameObject:[[AppModel sharedAppModel].currentGame npcForNpcId:typeId] fromSource:self];
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
    hideBackButton = h;
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

- (void) scriptRequestsOptionsPcMedia:(Media *)m
{
    [self.optionsViewController setDefaultMedia:m];
}

- (void) leaveConversationRequested
{
    if ([[self.npc.closing stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [self dismissSelf];
    }
    else{
        closingScriptPlaying = YES;
        [self displayScriptVC];
        [self.scriptViewController loadScriptOption:[[NpcScriptOption alloc] initWithOptionText:@"" scriptText:self.npc.closing nodeId:-1 hasViewed:NO]];
    }
}

- (void) dismissSelf
{
    [[AppServices sharedAppServices] updateServerNpcViewed:self.npc.npcId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

@end
