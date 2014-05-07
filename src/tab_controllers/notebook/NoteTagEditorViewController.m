//
//  NoteTagEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "NoteTagEditorViewController.h"
#import "NoteTagPredictionViewController.h"
#import "ARISTemplate.h"
#import "NoteTag.h"
#import "NoteTagView.h"
#import "AppModel.h"
#import "NotesModel.h"
#import "Game.h"

@interface NoteTagEditorViewController() <UITextFieldDelegate, NoteTagViewDelegate, NoteTagPredictionViewControllerDelegate>
{
    NSArray *tags;
    
    UIScrollView *existingTagsScrollView;
    UIImageView *plus;
    UIImageView *ex; 
    
    UITextField *tagInputField;
    NoteTagPredictionViewController *tagPredictionViewController;
    
    int expandHeight;
    BOOL editable;
    BOOL editing;
    
    id<NoteTagEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagEditorViewController

- (id) initWithTags:(NSArray *)t editable:(BOOL)e delegate:(id<NoteTagEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tags = t;
        editable = e;
        delegate = d;
        expandHeight = 100;
        editing = NO; 
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    existingTagsScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width-30,30)];
    
    plus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
    plus.frame = CGRectMake(self.view.frame.size.width-35,10,15,15);
    plus.userInteractionEnabled = YES;
    [plus addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTagButtonTouched)]];
    
    ex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete.png"]];
    ex.frame = CGRectMake(self.view.frame.size.width-35,10,15,15);
    ex.userInteractionEnabled = YES;
    [ex addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditButtonTouched)]]; 
    
    tagInputField = [[UITextField alloc] init];
    tagInputField.delegate = self;
    tagInputField.font = [ARISTemplate ARISTitleFont];
    tagInputField.placeholder = NSLocalizedString(@"NoteTagChooseLabelKey", @"");
    tagInputField.returnKeyType = UIReturnKeyDone; 
    
    tagPredictionViewController = [[NoteTagPredictionViewController alloc] 
                                   initWithGameNoteTags:_MODEL_GAME_.notesModel.gameNoteTags
                                   playerNoteTags:_MODEL_GAME_.notesModel.playerNoteTags 
                                   delegate:self];  
    
    [self stopEditing];
}

- (void) viewWillLayoutSubviews
{
    plus.frame = CGRectMake(self.view.frame.size.width-35, 10, plus.frame.size.width, plus.frame.size.height); 
    ex.frame = CGRectMake(self.view.frame.size.width-35, 10, ex.frame.size.width, ex.frame.size.height);  
    existingTagsScrollView.frame = CGRectMake(0,0,self.view.frame.size.width-30,30);  
    tagInputField.frame = CGRectMake(10, 2, self.view.frame.size.width-20,30);
    tagPredictionViewController.view.frame = CGRectMake(0,30,self.view.frame.size.width,expandHeight);  
}

- (void) setExpandHeight:(int)h
{
    expandHeight = h-30; //(subtract 30 for text field)
}

- (void) setTags:(NSArray *)t
{
    tags = t;
    [self refreshView];
}

- (void) refreshView
{
    //remove subviews
    while([[self.view subviews] count] != 0) [[[self.view subviews] objectAtIndex:0] removeFromSuperview]; 
    while([[existingTagsScrollView subviews] count] != 0) [[[existingTagsScrollView subviews] objectAtIndex:0] removeFromSuperview];
    
    UIView *tv;
    int x = 10;
    for(int i = 0; i < [tags count]; i++)
    {
        tv = [[NoteTagView alloc] initWithNoteTag:[tags objectAtIndex:i] editable:editable delegate:self];
        tv.frame = CGRectMake(x,5,tv.frame.size.width,tv.frame.size.height);
        x += tv.frame.size.width+10;
        [existingTagsScrollView addSubview:tv];
    }
    existingTagsScrollView.contentSize = CGSizeMake(x+10,30);
    
    if(editable && (editing || [tags count] == 0)) [self.view addSubview:tagInputField];
    else                                           [self.view addSubview:existingTagsScrollView];
    if(editable && !editing && [tags count] == 0)  [self.view addSubview:plus];
    if(editable && !editing && [tags count] > 0)   [self.view addSubview:ex]; 
    if(editing)
    {
        [tagPredictionViewController setGameNoteTags:_MODEL_GAME_.notesModel.gameNoteTags playerNoteTags:_MODEL_GAME_.notesModel.playerNoteTags];
        [self.view addSubview:tagPredictionViewController.view];   
        [tagInputField becomeFirstResponder];
        [self.view addSubview:ex];
    }
}

- (void) addTagButtonTouched
{
    [self beginEditing];
}

- (void) dismissEditButtonTouched
{
    if([tags count] > 0) { [delegate noteTagEditorDeletedTag:[tags objectAtIndex:0]]; [self beginEditing]; }
    else                 { [self stopEditing]; [self existingTagChosen:_MODEL_GAME_.notesModel.unlabeledTag]; }
}

- (void) beginEditing
{
    editing = YES; 
    [tagPredictionViewController queryString:@""];
    
    if((NSObject *)delegate && [((NSObject *)delegate) respondsToSelector:@selector(noteTagEditorWillBeginEditing)])
       [delegate noteTagEditorWillBeginEditing];  
    
    self.view.frame = CGRectMake(0,self.view.frame.origin.y,self.view.frame.size.width,130); 
    [self refreshView];    
}

- (void) stopEditing
{
    editing = NO;  
    [tagInputField resignFirstResponder]; 
    tagInputField.text = @"";
    
    self.view.frame = CGRectMake(0,self.view.frame.origin.y,self.view.frame.size.width,30); 
    [self refreshView];
}

// totally convoluted function- essentially "textFieldDidChange"
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //if backspace with already highlighted text... I know... weird
    if(range.location != 0 && range.length > 0 && string.length == 0) { range.location--; range.length++; }
    
    NSString *updatedInput = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSDictionary *matchedTags = [tagPredictionViewController queryString:updatedInput];
    
    NSArray *gnt = [matchedTags objectForKey:@"game"];
    NSArray *pnt = [matchedTags objectForKey:@"player"]; 
    NoteTag *nt;
    //If there's only one matched tag...
    if((gnt.count == 1 && pnt.count == 0 && (nt = [gnt objectAtIndex:0])) ||
       (gnt.count == 0 && pnt.count == 1 && (nt = [pnt objectAtIndex:0])))
    {
        //If curent input matches said tag FROM BEGINNING of string...
        if([nt.text rangeOfString:[NSString stringWithFormat:@"^%@.*",updatedInput] options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)  
        {
            //Set input to prediction with deltas highlighted for quick deletion
            NSString *hijackedInput = nt.text;
            tagInputField.text = hijackedInput; 
            UITextPosition *start = [tagInputField positionFromPosition:tagInputField.beginningOfDocument offset:updatedInput.length];
            UITextPosition *end = [tagInputField positionFromPosition:start offset:hijackedInput.length-updatedInput.length];
            [tagInputField setSelectedTextRange:[tagInputField textRangeFromPosition:start toPosition:end]];
            return NO;
        }
    }
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(!editing) [self beginEditing];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSArray *allValidTags = [_MODEL_GAME_.notesModel.gameNoteTags arrayByAddingObjectsFromArray:_MODEL_GAME_.notesModel.playerNoteTags];
    BOOL tagExists = NO;
    for(int i = 0; i < allValidTags.count; i++)
    {
        if([[((NoteTag *)[allValidTags objectAtIndex:i]).text lowercaseString] isEqualToString:[tagInputField.text lowercaseString]])
        {
            tagExists = YES;
            [delegate noteTagEditorAddedTag:[allValidTags objectAtIndex:i]];
            break;
        }
    }
    if(!tagExists && ![tagInputField.text isEqualToString:@""])
    {
        NoteTag *newNoteTag = [[NoteTag alloc] init];
        newNoteTag.text = tagInputField.text;
        newNoteTag.playerCreated = YES;
        [delegate noteTagEditorCreatedTag:newNoteTag]; 
    }
    else if(!tagExists)
        [delegate noteTagEditorCreatedTag:_MODEL_GAME_.notesModel.unlabeledTag];  
    [self stopEditing];
    return YES;
}

- (void) noteTagDeleteSelected:(NoteTag *)nt
{
    [delegate noteTagEditorDeletedTag:nt];
    [self refreshView];
}

- (void) existingTagChosen:(NoteTag *)nt
{
    [self stopEditing];
    if((NSObject *)delegate && [((NSObject *)delegate) respondsToSelector:@selector(noteTagEditorAddedTag:)]) 
        [delegate noteTagEditorAddedTag:nt];
}

@end
