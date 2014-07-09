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

@interface DialogScriptViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate>
{
    Dialog *dialog;
    DialogScript *script;
    
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
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    
    mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds delegate:self];
    [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidth];
    dialogTextView = [[DialogTextView alloc] init];
    collapseView = [[ARISCollapseView alloc] initWithContentView:dialogTextView frame:self.view.bounds open:YES showHandle:NO draggable:YES tappable:NO delegate:self];
    
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
    if([((NSNumber *)n.userInfo[@"dialog_script_id"]) intValue] != script.dialog_script_id) return;
    [dialogTextView setOptions:n.userInfo[@"options"]];
}

- (void) optionSelected:(DialogScript *)s
{
    [delegate dialogScriptChosen:s];
}

@end
