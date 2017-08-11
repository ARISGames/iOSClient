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
    DialogScript *script;
    NSArray *options;

    ARISMediaView *mediaView;
    ARISCollapseView *collapseView;
    DialogTextView *dialogTextView;

    long lastKnownTextFrameHeight;

    id<DialogScriptViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation DialogScriptViewController
@synthesize dialog;

- (id) initWithDialog:(Dialog *)n delegate:(id<DialogScriptViewControllerDelegate>)d
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
    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];

    CGRect b = self.view.bounds;
    CGRect mediaViewRect = CGRectMake(b.origin.x,b.origin.y+64,b.size.width,b.size.height-64);
    mediaView = [[ARISMediaView alloc] initWithFrame:mediaViewRect delegate:self];
    [mediaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToCV:)]];
    [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidth];
    dialogTextView = [[DialogTextView alloc] initWithDelegate:self];
    dialogTextView.frame = CGRectMake(0,0,self.view.bounds.size.width,10);
    dialogTextView.userInteractionEnabled = YES;
    collapseView = [[ARISCollapseView alloc] initWithContentView:dialogTextView frame:CGRectMake(0,self.view.bounds.size.height-40,self.view.bounds.size.width,40) open:YES showHandle:NO draggable:NO tappable:NO delegate:self];
    lastKnownTextFrameHeight = 40;

    [self.view addSubview:mediaView];
    [self.view addSubview:collapseView];
}

- (void) loadScript:(DialogScript *)s guessedHeight:(long)h
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
        if ([c.title isEqualToString:@""]) {
            [delegate setNavTitle:c.name];
        } else {
            [delegate setNavTitle:c.title];
        }
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

- (void) dialogTextView:(DialogTextView *)dtv selectedOption:(long)o
{
    DialogOption *op = options[o];
    if([op.link_type isEqualToString:@"DIALOG_SCRIPT"])
        [delegate dialogScriptChosen:[_MODEL_DIALOGS_ scriptForId:op.link_id]];
    else if([op.link_type isEqualToString:@"EXIT"])
    {                                                                                    [delegate exitRequested]; }
    else if([op.link_type isEqualToString:@"EXIT_TO_PLAQUE"])
    { [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_PLAQUES_ plaqueForId:op.link_id]];    [delegate exitRequested]; }
    else if([op.link_type isEqualToString:@"EXIT_TO_ITEM"])
    { [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_ITEMS_ itemForId:op.link_id]];        [delegate exitRequested]; }
    else if([op.link_type isEqualToString:@"EXIT_TO_WEB_PAGE"])
    { [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_WEB_PAGES_ webPageForId:op.link_id]]; [delegate exitRequested]; }
    else if([op.link_type isEqualToString:@"EXIT_TO_DIALOG"])
    {
        // Optimized: reuse the same controllers, just switch it to a new dialog
        [delegate dialogScriptChosen:[_MODEL_DIALOGS_ scriptForId:[_MODEL_DIALOGS_ dialogForId:op.link_id].intro_dialog_script_id]];
    }
    else if([op.link_type isEqualToString:@"EXIT_TO_TAB"])
    {
        Tab *t = [_MODEL_TABS_ tabForId:op.link_id];
        if ([t.type isEqualToString:@"AUGMENTED"] && op.link_info && ![op.link_info isEqualToString:@"scanner"] && ![op.link_info isEqualToString:@"Scanner"] && ![op.link_info isEqualToString:@""]) {
            [_MODEL_TABS_ tabForType:@"AUGMENTED"].info = [NSString stringWithFormat:@"|%@", op.link_info];
        }
        [_MODEL_DISPLAY_QUEUE_ enqueueTab:t];
        [delegate exitRequested];
    }
}

- (void) passTapToCV:(UITapGestureRecognizer *)g
{
    //[collapseView handleTapped:g];
}

- (long) heightOfTextBox
{
    return lastKnownTextFrameHeight;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
