//
//  DialogScriptViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "DialogScriptViewController.h"
#import "ARISMediaView.h"
#import "ARISCollapseView.h"
#import "DialogTextView.h"
#import "AppModel.h"
#import "User.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DialogScriptViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate, DialogTextViewDelegate>
{
    Dialog *dialog;
    DialogScript *script;
    NSArray *options;

    ARISMediaView *mediaView;
    ARISCollapseView *collapseView;
    DialogTextView *dialogTextView;

    id<DialogScriptViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation DialogScriptViewController

- (id) initWithDialog:(Dialog *)n delegate:(id<DialogScriptViewControllerDelegate>)d
{
    if(self = [super init])
    {
        dialog = n;
        delegate = d;
        _ARIS_NOTIF_LISTEN_(@"MODEL_SCRIPT_OPTIONS_AVAILABLE", self, @selector(scriptOptionsAvailable:), nil);
    }
    return self; 
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];

    mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds delegate:self];
    [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidth];
    dialogTextView = [[DialogTextView alloc] initWithDelegate:self];
    dialogTextView.frame = CGRectMake(0,0,self.view.bounds.size.width,10);
    dialogTextView.userInteractionEnabled = YES;
    collapseView = [[ARISCollapseView alloc] initWithContentView:dialogTextView frame:self.view.bounds open:YES showHandle:YES draggable:YES tappable:YES delegate:self];

    [self.view addSubview:mediaView];
    [self.view addSubview:collapseView]; 
}

- (void) loadScript:(DialogScript *)s
{
    script = s;
    if(!s.dialog_character_id) //'you' character
    {
        if(_MODEL_PLAYER_.media_id) [mediaView setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id]];
        else [mediaView setImage:[UIImage imageNamed:@"defaultCharacter.png"]];
    }
    else
    {
        DialogCharacter *c = [_MODEL_DIALOGS_ characterForId:s.dialog_character_id];
        if(c.media_id) [mediaView setMedia:[_MODEL_MEDIA_ mediaForId:c.media_id]];
        else [mediaView setImage:[UIImage imageNamed:@"defaultCharacter.png"]];
    }
    [dialogTextView loadText:s.text];
    [dialogTextView setOptionsLoading]; 
    [_MODEL_DIALOGS_ requestPlayerOptionsForDialogId:dialog.dialog_id scriptId:s.dialog_script_id];
}

- (void) scriptOptionsAvailable:(NSNotification *)n
{
    if(!script || [((NSNumber *)n.userInfo[@"dialog_script_id"]) intValue] != script.dialog_script_id) return;
    options = n.userInfo[@"options"];
    [dialogTextView setOptions:options];
}

- (void) dialogTextView:(DialogTextView *)dtv expandedToSize:(CGSize)s
{
    [collapseView setContentFrameHeight:s.height];
    [collapseView setFrameHeight:s.height]; 
}

- (void) dialogTextView:(DialogTextView *)dtv selectedOption:(int)o
{
  [delegate dialogScriptChosen:options[o]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
