//
//  DialogViewController.m
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import "DialogViewController.h"
#import "Dialog.h"
#import "DialogOptionsViewController.h"
#import "DialogScriptViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "StateControllerProtocol.h"

@interface DialogViewController() <DialogOptionsViewControllerDelegate, DialogScriptViewControllerDelegate, AVAudioPlayerDelegate>
{
    Dialog *dialog;
    DialogScriptViewController  *scriptViewController;
    DialogOptionsViewController *optionsViewController;
    
    UIButton *backButton;
    
    BOOL closingScriptPlaying;
    id<GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) Dialog *dialog;
@property (nonatomic, strong) DialogScriptViewController  *scriptViewController;
@property (nonatomic, strong) DialogOptionsViewController *optionsViewController;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation DialogViewController
/*

@synthesize dialog;
@synthesize scriptViewController;
@synthesize optionsViewController;
@synthesize backButton;

- (id) initWithDialog:(Dialog *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d
{
    if((self = [super init]))
    {
        self.dialog = n;
        closingScriptPlaying = NO;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorDialogContentBackdrop];
    
    self.optionsViewController = [[DialogOptionsViewController alloc] initWithFrame:self.view.bounds delegate:self];
    self.optionsViewController.view.alpha = 0.0; 
    self.scriptViewController  = [[DialogScriptViewController alloc] initWithDialog:self.dialog frame:self.view.bounds delegate:self]; 
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
}

- (void) viewDidAppearFirstTime:(BOOL)animated
{
    [super viewDidAppearFirstTime:animated];
    
    if([[self.dialog.greeting stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        [self displayOptionsVC];
        [self.optionsViewController loadOptionsForDialog:self.dialog afterViewingOption:nil];
    }
    else
    {
        [self displayScriptVC];
        [self.scriptViewController loadScriptOption:[[DialogScriptOption alloc] initWithOptionText:@"" scriptText:self.dialog.greeting plaque_id:-1 hasViewed:NO]];
    }
}

- (void) optionChosen:(DialogScriptOption *)o
{
    self.option = o;
    [self.scriptViewController loadScriptOption:self.option];
    [self displayScriptVC];
}

- (void) scriptEndedExitToType:(NSString *)type title:(NSString *)title id:(int)typeId
{
    if(closingScriptPlaying && !type)
    {
        [_SERVICES_ updateServerPlaqueViewed:self.option.plaque_id fromLocation:0];
        [self dismissSelf];
    }
    
    if(type)
    {
        [_SERVICES_ updateServerPlaqueViewed:self.option.plaque_id fromLocation:0];
        [self dismissSelf];
        
        if([type isEqualToString:@"tab"])
            [delegate displayTab:title];
        if([type isEqualToString:@"scanner"])
            [delegate displayScannerWithPrompt:title]; 
        else if([type isEqualToString:@"plaque"])
            [delegate displayGameObject:[_MODEL_PLAQUES_ plaqueForId:typeId] fromSource:self];
        else if([type isEqualToString:@"webpage"])
            [delegate displayGameObject:[_MODEL_WEBPAGES_ webPageForId:typeId] fromSource:self];
        else if([type isEqualToString:@"item"])
            [delegate displayGameObject:[_MODEL_ITEMS_ itemForId:typeId] fromSource:self];
        else if([type isEqualToString:@"character"])
            [delegate displayGameObject:[_MODEL_DIALOGS_ dialogForId:typeId] fromSource:self];
    }
    else
    {
        [self.optionsViewController loadOptionsForDialog:self.dialog afterViewingOption:self.option];
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

- (void) scriptRequestsOptionsPcMedia:(Media *)m
{
    [self.optionsViewController setDefaultMedia:m];
}

- (void) leaveConversationRequested
{
    if ([[self.dialog.closing stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [self dismissSelf];
    }
    else{
        closingScriptPlaying = YES;
        [self displayScriptVC];
        [self.scriptViewController loadScriptOption:[[DialogScriptOption alloc] initWithOptionText:@"" scriptText:self.dialog.closing plaque_id:-1 hasViewed:NO]];
    }
}

- (void) dismissSelf
{
    [_SERVICES_ updateServerDialogViewed:self.dialog.dialog_id fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}
*/

@end
