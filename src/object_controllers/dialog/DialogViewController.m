//
//  DialogViewController.m
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import "DialogViewController.h"
#import "Dialog.h"
#import "DialogScript.h"
#import "DialogScriptViewController.h"
#import "AppModel.h"
#import "ARISMediaView.h"

@interface DialogViewController() <DialogScriptViewControllerDelegate>
{
    Dialog *dialog;
    Instance *instance;
    Tab *tab;

    //holds 2 DialogScriptVC's, and flips between them like a graphics buffer
    //for smooth transitions/easy organization
    //(if the word 'buffer' confuses you, you're thinking too hard. just a place to load
    //content/data/animations without disturbing what's currently displayed, and can be
    //quickly and cleanly swapped out with what IS currently displayed as a whole)
    NSMutableArray *youViewControllers;
    long currentYouViewController;

    NSMutableArray *themViewControllers;
    long currentThemViewController;

    UIButton *backButton;

    //For easy recall/reference
    CGRect centerFrame;
    CGRect leftFrame;
    CGRect rightFrame;

    id<DialogViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation DialogViewController

- (id) initWithInstance:(Instance *)i delegate:(id<DialogViewControllerDelegate>)d
{
    if(self = [super init])
    {
        instance = i;
        dialog = [_MODEL_DIALOGS_ dialogForId:i.object_id];
        delegate = d;
    }
    return self;
}
- (Instance *) instance { return instance; }

- (id) initWithTab:(Tab *)t delegate:(id<DialogViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tab = t;
        instance = [_MODEL_INSTANCES_ instanceForId:0]; //get null inst
        instance.object_type = tab.type;
        instance.object_id = tab.content_id;
        dialog = [_MODEL_DIALOGS_ dialogForId:instance.object_id];
        delegate = d;
    }
    return self;
}
- (Tab *) tab { return tab; }

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];

    //this should go in viewwilllayoutsubviews, but apple is terrible
    centerFrame = self.view.bounds;
    leftFrame = CGRectMake(0-centerFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
    rightFrame = CGRectMake(centerFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);

    youViewControllers = [[NSMutableArray alloc] init];
    youViewControllers[0] = [[DialogScriptViewController alloc] initWithDialog:dialog delegate:self];
    youViewControllers[1] = [[DialogScriptViewController alloc] initWithDialog:dialog delegate:self];
    ((UIViewController *)youViewControllers[0]).view.frame = leftFrame;
    ((UIViewController *)youViewControllers[1]).view.frame = leftFrame;
    ((UIViewController *)youViewControllers[0]).view.opaque = NO;
    ((UIViewController *)youViewControllers[1]).view.opaque = NO;
    [self.view addSubview:((UIViewController *)youViewControllers[0]).view];
    [self.view addSubview:((UIViewController *)youViewControllers[1]).view];
    currentYouViewController = 0;

    themViewControllers = [[NSMutableArray alloc] init];
    themViewControllers[0] = [[DialogScriptViewController alloc] initWithDialog:dialog delegate:self];
    themViewControllers[1] = [[DialogScriptViewController alloc] initWithDialog:dialog delegate:self];
    ((UIViewController *)themViewControllers[0]).view.frame = rightFrame;
    ((UIViewController *)themViewControllers[1]).view.frame = rightFrame;
    ((UIViewController *)themViewControllers[0]).view.opaque = NO;
    ((UIViewController *)themViewControllers[1]).view.opaque = NO;
    [self.view addSubview:((UIViewController *)themViewControllers[0]).view];
    [self.view addSubview:((UIViewController *)themViewControllers[1]).view];
    currentThemViewController = 0;

    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];

    //yes, in 'loadview' which is a bit odd.
    DialogScript *script = [_MODEL_DIALOGS_ scriptForId:dialog.intro_dialog_script_id];
    if(dialog.intro_dialog_script_id == 0) script.dialog_id = dialog.dialog_id; //the 'null script'
    [self dialogScriptChosen:script];
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  if(!dialog || dialog.back_button_enabled)
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(tab)
    {
        UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
        [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
        [threeLineNavButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        threeLineNavButton.accessibilityLabel = @"In-Game Menu";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
    }
}

/*
 Note about transition states:
 A transition moves from one consistent state to another. It presupposes it is in a consistent state before starting.
 Either the YouVCs are centered on screen, OR the ThemVCs are centered on screen (NOT both).
 If the YouVCs are not on screen, they are off the screen to the LEFT.
 If the ThemVCs are not on screen, they are off the screen to the RIGHT.
 ALL VCs ARE ALWAYS AT 1.0f ALPHA (UNLESS in the middle of a transition).
 The YouVCs are always exactly stacked on top of eachother. Same for the ThemVCs.
*/
- (void) dialogScriptChosen:(DialogScript *)s
{
    // switch dialogs if necessary
    if (s.dialog_id != dialog.dialog_id) {
        dialog = [_MODEL_DIALOGS_ dialogForId:s.dialog_id];
        ((DialogScriptViewController *)youViewControllers[0]).dialog = dialog;
        ((DialogScriptViewController *)youViewControllers[1]).dialog = dialog;
        ((DialogScriptViewController *)themViewControllers[0]).dialog = dialog;
        ((DialogScriptViewController *)themViewControllers[1]).dialog = dialog;
    }

    if(s.event_package_id) [_MODEL_EVENTS_ runEventPackageId:s.event_package_id];
    [_MODEL_LOGS_ playerViewedContent:@"DIALOG_SCRIPT" id:s.dialog_script_id];
    if(s.dialog_character_id == 0)
    {
        DialogScriptViewController *old_vc = youViewControllers[currentYouViewController]; //for readability
        currentYouViewController = (currentYouViewController+1)%2;
        DialogScriptViewController *new_vc = youViewControllers[currentYouViewController]; //for readability

        //set 'to be displayed' vc buffer to alpha 0 (to be animated to 1.0) if transition is in-place
        if(new_vc.view.frame.origin.x != centerFrame.origin.x) new_vc.view.alpha = 0.0f;

        [new_vc loadScript:s guessedHeight:old_vc.heightOfTextBox]; //populate it with content
        [self.view bringSubviewToFront:new_vc.view]; //bring it to front

       [UIView beginAnimations:@"transition" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.25];
        new_vc.view.alpha = 1.0;
        ((UIViewController *)youViewControllers[0]).view.frame = centerFrame;
        ((UIViewController *)youViewControllers[1]).view.frame = centerFrame;
        ((UIViewController *)themViewControllers[0]).view.frame = rightFrame;
        ((UIViewController *)themViewControllers[1]).view.frame = rightFrame;
        [UIView commitAnimations];
    }
    else
    {
        DialogScriptViewController *old_vc = themViewControllers[currentThemViewController]; //for readability
        currentThemViewController = (currentThemViewController+1)%2;
        DialogScriptViewController *new_vc = themViewControllers[currentThemViewController]; //for readability

        //set 'to be displayed' vc buffer to alpha 0 (to be animated to 1.0) if transition is in-place
        if(new_vc.view.frame.origin.x != centerFrame.origin.x) new_vc.view.alpha = 0.0f;

        [new_vc loadScript:s guessedHeight:old_vc.heightOfTextBox]; //populate it with content
        [self.view bringSubviewToFront:new_vc.view]; //bring it to front

        [UIView beginAnimations:@"transition" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.25];
        new_vc.view.alpha = 1.0;
        ((UIViewController *)themViewControllers[0]).view.frame = centerFrame;
        ((UIViewController *)themViewControllers[1]).view.frame = centerFrame;
        ((UIViewController *)youViewControllers[0]).view.frame = leftFrame;
        ((UIViewController *)youViewControllers[1]).view.frame = leftFrame;
        [UIView commitAnimations];
    }
}

- (void) setNavTitle:(NSString *)title
{
  self.title = title;
  self.navigationItem.title = title;
}

- (void) exitRequested
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [delegate instantiableViewControllerRequestsDismissal:self];
    if(tab) [self showNav];
}

- (void) showNav
{
    [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"DIALOG"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; if(dialog.name && ![dialog.name isEqualToString:@""]) return dialog.name; return @"Dialog"; }
- (ARISMediaView *) tabIcon
{
  ARISMediaView *amv = [[ARISMediaView alloc] init];
  if(tab.icon_media_id)
    [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
  else if(dialog.icon_media_id)
    [amv setMedia:[_MODEL_MEDIA_ mediaForId:dialog.icon_media_id]];
  else
    [amv setImage:[UIImage imageNamed:@"logo_icon"]];
  return amv;
}

@end
