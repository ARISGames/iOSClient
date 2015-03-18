//
//  NoteTagEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "NoteTagEditorViewController.h"
#import "NoteTagPredictionViewController.h"
#import "NoteTagView.h"
#import "AppModel.h"
#import "NotesModel.h"
#import "Game.h"

@interface NoteTagEditorViewController() <UITextFieldDelegate, NoteTagViewDelegate, NoteTagPredictionViewControllerDelegate>
{
    Tag *tag;

    UIScrollView *existingTagsScrollView;
    UIImageView *plus;
    UIImageView *ex;

    UITextField *tagInputField;
    NoteTagPredictionViewController *tagPredictionViewController;

    long expandHeight;
    BOOL editable;
    BOOL editing;

    id<NoteTagEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagEditorViewController

- (id) initWithTag:(Tag *)t editable:(BOOL)e delegate:(id<NoteTagEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tag = t;
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
    plus.frame = CGRectMake(self.view.frame.size.width-35,0,30,30);
    plus.userInteractionEnabled = YES;
    [plus addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTagButtonTouched)]];

    ex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete.png"]];
    ex.frame = CGRectMake(self.view.frame.size.width-35,0,30,30);
    ex.userInteractionEnabled = YES;
    [ex addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditButtonTouched)]];

    tagInputField = [[UITextField alloc] init];
    tagInputField.delegate = self;
    tagInputField.font = [ARISTemplate ARISTitleFont];
    tagInputField.placeholder = NSLocalizedString(@"NoteTagChooseLabelKey", @"");
    tagInputField.returnKeyType = UIReturnKeyDone;

    tagPredictionViewController = [[NoteTagPredictionViewController alloc] initWithTags:_MODEL_TAGS_.tags delegate:self];

    [self stopEditing];
}

- (void) viewWillLayoutSubviews
{
    plus.frame = CGRectMake(self.view.frame.size.width-35, 0, plus.frame.size.width, plus.frame.size.height);
    ex.frame = CGRectMake(self.view.frame.size.width-35, 0, ex.frame.size.width, ex.frame.size.height);
    existingTagsScrollView.frame = CGRectMake(0,0,self.view.frame.size.width-30,40);
    tagInputField.frame = CGRectMake(10, 2, self.view.frame.size.width-20,30);
    tagPredictionViewController.view.frame = CGRectMake(0,30,self.view.frame.size.width,expandHeight);
}

- (void) setExpandHeight:(long)h
{
    expandHeight = h-30; //(subtract 30 for text field)
}

- (void) setTag:(Tag *)t
{
    tag = t;
    [self refreshView];
}

- (void) refreshView
{
    //remove subviews
    while([self.view subviews].count != 0) [[[self.view subviews] objectAtIndex:0] removeFromSuperview];
    while([existingTagsScrollView subviews].count != 0) [[[existingTagsScrollView subviews] objectAtIndex:0] removeFromSuperview];

    UIView *tv;
    long x = 10;
    if(tag)
    {
        tv = [[NoteTagView alloc] initWithNoteTag:tag editable:editable delegate:self];
        tv.frame = CGRectMake(x,0,tv.frame.size.width,tv.frame.size.height);
        x += tv.frame.size.width+10;
        [existingTagsScrollView addSubview:tv];
    }
    existingTagsScrollView.contentSize = CGSizeMake(x+10,40);

    if(editable && (editing || !tag)) [self.view addSubview:tagInputField];
    else                              [self.view addSubview:existingTagsScrollView];
    if(editable && !editing && !tag)  [self.view addSubview:plus];
    if(editable && !editing && tag)   [self.view addSubview:ex];
    if(editing)
    {
        [tagPredictionViewController setTags:_MODEL_TAGS_.tags];
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
    if(tag) { [delegate noteTagEditorDeletedTag:tag]; [self beginEditing]; }
    else    { [self stopEditing]; [self existingTagChosen:nil]; }
}

- (void) beginEditing
{
    editing = YES;
    [tagPredictionViewController queryString:@""];

    if((NSObject *)delegate && [((NSObject *)delegate) respondsToSelector:@selector(noteTagEditorWillBeginEditing)])
       [delegate noteTagEditorWillBeginEditing];

    self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,expandHeight+30);
    [self refreshView];
}

- (void) stopEditing
{
    editing = NO;
    [tagInputField resignFirstResponder];
    tagInputField.text = @"";

    self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,30);
    [self refreshView];
}

// totally convoluted function- essentially "textFieldDidChange"
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //if backspace with already highlighted text... I know... weird
    if(range.location != 0 && range.length > 0 && string.length == 0) { range.location--; range.length++; }

    NSString *updatedInput = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *matched = [tagPredictionViewController queryString:updatedInput];

    Tag *nt;
    //If there's only one matched tag...
    if(matched.count == 1 && (nt = [matched objectAtIndex:0]))
    {
        //If curent input matches said tag FROM BEGINNING of string...
        if([nt.tag rangeOfString:[NSString stringWithFormat:@"^%@.*",updatedInput] options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)
        {
            //Set input to prediction with deltas highlighted for quick deletion
            NSString *hijackedInput = nt.tag;
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
    NSArray *allValidTags = _MODEL_TAGS_.tags;
    BOOL tagExists = NO;
    for(long i = 0; i < allValidTags.count; i++)
    {
        if([[((Tag *)[allValidTags objectAtIndex:i]).tag lowercaseString] isEqualToString:[tagInputField.text lowercaseString]])
        {
            tagExists = YES;
            [delegate noteTagEditorAddedTag:[allValidTags objectAtIndex:i]];
            break;
        }
    }
    if(!tagExists)
        [delegate noteTagEditorCancelled];
    [self stopEditing];
    return YES;
}

- (void) noteTagDeleteSelected:(Tag *)nt
{
    [delegate noteTagEditorDeletedTag:nt];
    [self refreshView];
}

- (void) existingTagChosen:(Tag *)nt
{
    [self stopEditing];
    if((NSObject *)delegate && [((NSObject *)delegate) respondsToSelector:@selector(noteTagEditorAddedTag:)])
      [delegate noteTagEditorAddedTag:nt];
}

@end
