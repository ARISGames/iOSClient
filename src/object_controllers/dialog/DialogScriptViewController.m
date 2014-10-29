//
//  DialogScriptViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "DialogScriptViewController.h"
#import "StateControllerProtocol.h"
#import "ARISMediaView.h"
#import "ARISCollapseView.h"
#import "DialogTextView.h"
#import "AppModel.h"
#import "User.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DialogScriptViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate, DialogTextViewDelegate, StateControllerProtocol>
{
    Dialog *dialog;
    DialogScript *script;
    NSArray *options;

    ARISMediaView *mediaView;
    ARISCollapseView *collapseView;
    DialogTextView *dialogTextView;
    
    int lastKnownTextFrameHeight;

    id<DialogScriptViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end

@implementation DialogScriptViewController

- (id) initWithDialog:(Dialog *)n delegate:(id<DialogScriptViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super init])
    {
        dialog = n;
        delegate = d;
        _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_SCRIPT_OPTIONS_AVAILABLE", self, @selector(scriptOptionsAvailable:), nil);
    }
    return self; 
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];

    mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds delegate:self];
    [mediaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToCV:)]];
    [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidth];
    dialogTextView = [[DialogTextView alloc] initWithDelegate:self];
    dialogTextView.frame = CGRectMake(0,0,self.view.bounds.size.width,10);
    dialogTextView.userInteractionEnabled = YES;
    collapseView = [[ARISCollapseView alloc] initWithContentView:dialogTextView frame:CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];
    lastKnownTextFrameHeight = 40;

    [self.view addSubview:mediaView];
    [self.view addSubview:collapseView]; 
}

- (void) loadScript:(DialogScript *)s guessedHeight:(int)h
{
    script = s;
    if(!s.dialog_character_id) //'you' character
    {
        if(_MODEL_PLAYER_.media_id) [mediaView setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id]];
        else [mediaView setImage:[UIImage imageNamed:@"defaultCharacter.png"]];
        [delegate setNavTitle:_MODEL_PLAYER_.display_name];
    }
    else
    {
        DialogCharacter *c = [_MODEL_DIALOGS_ characterForId:s.dialog_character_id];
        if(c.media_id) [mediaView setMedia:[_MODEL_MEDIA_ mediaForId:c.media_id]];
        else [mediaView setImage:[UIImage imageNamed:@"defaultCharacter.png"]];
        [delegate setNavTitle:c.name];
    }
    [dialogTextView loadText:s.text];
    [dialogTextView setOptionsLoading]; 
    [collapseView setContentFrameHeightSilently:h];
    [collapseView setFrameHeightSilently:h+10]; 
    lastKnownTextFrameHeight = h;
    [_MODEL_DIALOGS_ requestPlayerOptionsForDialogId:dialog.dialog_id scriptId:s.dialog_script_id];
}

- (void) scriptOptionsAvailable:(NSNotification *)n
{
    if(!script || [((NSNumber *)n.userInfo[@"dialog_script_id"]) intValue] != script.dialog_script_id) return;
    options = _ARIS_ARRAY_SORTED_ON_(n.userInfo[@"options"], @"sort_index");
    [dialogTextView setOptions:options];
}

- (void) dialogTextView:(DialogTextView *)dtv expandedToSize:(CGSize)s
{
    [collapseView setContentFrameHeight:s.height];
    [collapseView setFrameHeight:s.height+10]; 
    lastKnownTextFrameHeight = s.height;
}

- (void) dialogTextView:(DialogTextView *)dtv selectedOption:(int)o
{
    DialogOption *op = options[o];
    if([op.link_type isEqualToString:@"DIALOG_SCRIPT"])
        [delegate dialogScriptChosen:[_MODEL_DIALOGS_ scriptForId:op.link_id]];
    else if([op.link_type isEqualToString:@"EXIT"])
        [delegate exitRequested];
    else if([op.link_type isEqualToString:@"EXIT_TO_PLAQUE"])
        [delegate displayObjectType:@"PLAQUE" id:op.link_id];
    else if([op.link_type isEqualToString:@"EXIT_TO_ITEM"])
        [delegate displayObjectType:@"ITEM" id:op.link_id];
    else if([op.link_type isEqualToString:@"EXIT_TO_WEB_PAGE"])
        [delegate displayObjectType:@"WEB_PAGE" id:op.link_id];
    else if([op.link_type isEqualToString:@"EXIT_TO_DIALOG"])
        [delegate displayObjectType:@"DIALOG" id:op.link_id];
    else if([op.link_type isEqualToString:@"EXIT_TO_TAB"])
        [delegate displayTabId:op.link_id];
}

- (void) passTapToCV:(UITapGestureRecognizer *)g
{
    [collapseView handleTapped:g];
}

- (int) heightOfTextBox
{
    return lastKnownTextFrameHeight;
}

//implement statecontrol stuff for webpage, but just delegate any requests
- (BOOL) displayTrigger:(Trigger *)t   { return [delegate displayTrigger:t]; }
- (BOOL) displayTriggerId:(int)t       { return [delegate displayTriggerId:t]; }
- (BOOL) displayInstance:(Instance *)i { return [delegate displayInstance:i]; }
- (BOOL) displayInstanceId:(int)i      { return [delegate displayInstanceId:i]; }
- (BOOL) displayObject:(id)o           { return [delegate displayObject:o]; }
- (BOOL) displayObjectType:(NSString *)type id:(int)type_id { return [delegate displayObjectType:type id:type_id]; }
- (void) displayTab:(Tab *)t           { [delegate displayTab:t]; }
- (void) displayTabId:(int)t           { [delegate displayTabId:t]; }
- (void) displayTabType:(NSString *)t  { [delegate displayTabType:t]; }
- (void) displayScannerWithPrompt:(NSString *)p { [delegate displayScannerWithPrompt:p]; }

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
