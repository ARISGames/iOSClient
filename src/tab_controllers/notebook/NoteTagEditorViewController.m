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
#import "AppModel.h"
#import "NotesModel.h"
#import "Game.h"

@interface NoteTagEditorViewController() <UITextFieldDelegate, NoteTagPredictionViewControllerDelegate>
{
    NSArray *tags;
    
    UIScrollView *existingTagsScrollView;
    UILabel *plus;
    UILabel *minus; 
    UIImageView *grad;
    
    UITextField *tagInputField;
    NoteTagPredictionViewController *tagPredictionViewController;
    
    BOOL editable;
    
    BOOL appleStopTryingToDoStuffWithoutMyPermission;
    
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
        appleStopTryingToDoStuffWithoutMyPermission = NO;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    existingTagsScrollView  = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width-30,30)];
    
    int width = [@" + " sizeWithFont:[ARISTemplate ARISBodyFont]].width;
    
    //make "plus" in similar way to tags
    plus = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25,5,width,20)];
    plus.font = [ARISTemplate ARISBodyFont];
    plus.textColor = [UIColor whiteColor];
    plus.backgroundColor = [UIColor ARISColorLightBlue];
    plus.text = @" + ";
    plus.layer.cornerRadius = 8;
    plus.layer.masksToBounds = YES;
    plus.userInteractionEnabled = YES;
    [plus addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTagButtonTouched)]];
    
    //make "minus" in similar way to tags
    minus = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25,5,width,20)];
    minus.font = [ARISTemplate ARISBodyFont];
    minus.textColor = [UIColor whiteColor];
    minus.backgroundColor = [UIColor ARISColorLightBlue];
    minus.text = @" - ";
    minus.layer.cornerRadius = 8;
    minus.layer.masksToBounds = YES;
    minus.userInteractionEnabled = YES;
    [minus addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTagButtonTouched)]];
    
    grad = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_white_gradient"]];
    grad.frame = CGRectMake(self.view.frame.size.width-55,0,30,30);
    
    [self refreshViewFromTags];  
    [self.view addSubview:existingTagsScrollView];
    if(editable) [self.view addSubview:plus]; 
    [self.view addSubview:grad]; 
    
    tagInputField = [[UITextField alloc] init];
    tagInputField.delegate = self;
    tagInputField.font = [ARISTemplate ARISTitleFont]; 
    tagInputField.placeholder = @" tag";
    tagInputField.returnKeyType = UIReturnKeyDone; 
    tagPredictionViewController = [[NoteTagPredictionViewController alloc] 
                                   initWithGameNoteTags:[AppModel sharedAppModel].currentGame.notesModel.gameNoteTags
                                   playerNoteTags:[AppModel sharedAppModel].currentGame.notesModel.playerNoteTags 
                                   delegate:self];  
}

- (void) viewWillLayoutSubviews
{
    if(!appleStopTryingToDoStuffWithoutMyPermission)
    {
        plus.frame = CGRectMake(self.view.frame.size.width-25, 5, plus.frame.size.width, plus.frame.size.height); 
        grad.frame = CGRectMake(self.view.frame.size.width-55,0,30,30); 
        existingTagsScrollView.frame = CGRectMake(0,0,self.view.frame.size.width-30,30);  
        tagInputField.frame = CGRectMake(10, 0, self.view.frame.size.width-20,30);
        tagPredictionViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width,100);  
    }
    appleStopTryingToDoStuffWithoutMyPermission = NO; 
}

- (void) setTags:(NSArray *)t
{
    tags = t;
    [self refreshViewFromTags];
}

- (UIView *) tagViewForTag:(NoteTag *)t
{
    int width;
    if(editable) width = [[NSString stringWithFormat:@" %@ x ",t.text] sizeWithFont:[ARISTemplate ARISBodyFont]].width;
    else         width = [[NSString stringWithFormat:@" %@ ",  t.text] sizeWithFont:[ARISTemplate ARISBodyFont]].width;
    UILabel *tagView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,20)];
    tagView.font = [ARISTemplate ARISBodyFont];
    tagView.textColor = [UIColor whiteColor];
    tagView.backgroundColor = [UIColor ARISColorLightBlue];
    if(editable) tagView.text = [NSString stringWithFormat:@" %@ x ",t.text];
    else         tagView.text = [NSString stringWithFormat:@" %@ ",t.text]; 
    tagView.layer.cornerRadius = 8;
    tagView.layer.masksToBounds = YES;
    return tagView;
}

- (void) refreshViewFromTags
{
    while([[existingTagsScrollView subviews] count] != 0) [[[existingTagsScrollView subviews] objectAtIndex:0] removeFromSuperview];
    
    UIView *tv;
    int x = 10;
    for(int i = 0; i < [tags count]; i++)
    {
        tv = [self tagViewForTag:[tags objectAtIndex:i]];
        tv.frame = CGRectMake(x,5,tv.frame.size.width,tv.frame.size.height);
        x += tv.frame.size.width+10;
        [existingTagsScrollView addSubview:tv];
    }
    existingTagsScrollView.contentSize = CGSizeMake(x+20,30);
}

- (void) addTagButtonTouched
{
    [self.view addSubview:tagInputField];
    [self.view addSubview:tagPredictionViewController.view]; 
    
    if((NSObject *)delegate && [((NSObject *)delegate) respondsToSelector:@selector(noteTagEditorWillBeginEditing)])
       [delegate noteTagEditorWillBeginEditing];  
    [tagInputField becomeFirstResponder]; 
    [self expandView];
}

- (void) stopEditing
{
    tagInputField.text = @"";
    if(self.view.frame.size.height > 100) //totally bs guess
     [self textFieldShouldReturn:tagInputField];
}

- (void) expandView
{
    self.view.frame = CGRectMake(0,self.view.frame.origin.y-100,self.view.frame.size.width,self.view.frame.size.height+100);
    
    tagPredictionViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width,100);
    existingTagsScrollView.frame = CGRectMake(existingTagsScrollView.frame.origin.x,existingTagsScrollView.frame.origin.y+100,existingTagsScrollView.frame.size.width,existingTagsScrollView.frame.size.height);
    plus.frame  = CGRectMake( plus.frame.origin.x, plus.frame.origin.y+100, plus.frame.size.width, plus.frame.size.height); 
    minus.frame = CGRectMake(minus.frame.origin.x,minus.frame.origin.y+100,minus.frame.size.width,minus.frame.size.height); 
    grad.frame  = CGRectMake( grad.frame.origin.x, grad.frame.origin.y+100, grad.frame.size.width, grad.frame.size.height); 
    tagInputField.frame = CGRectMake(tagInputField.frame.origin.x,tagInputField.frame.origin.y+100,tagInputField.frame.size.width,tagInputField.frame.size.height); 
    
    appleStopTryingToDoStuffWithoutMyPermission = YES;
}

- (void) retractView
{
    self.view.frame = CGRectMake(0,self.view.frame.origin.y+100,self.view.frame.size.width,self.view.frame.size.height-100);
    
    existingTagsScrollView.frame = CGRectMake(existingTagsScrollView.frame.origin.x,existingTagsScrollView.frame.origin.y-100,existingTagsScrollView.frame.size.width,existingTagsScrollView.frame.size.height);
    plus.frame = CGRectMake(plus.frame.origin.x,plus.frame.origin.y-100,plus.frame.size.width,plus.frame.size.height); 
    minus.frame = CGRectMake(minus.frame.origin.x,minus.frame.origin.y-100,minus.frame.size.width,minus.frame.size.height); 
    grad.frame = CGRectMake(grad.frame.origin.x,grad.frame.origin.y-100,grad.frame.size.width,grad.frame.size.height); 
    tagInputField.frame = CGRectMake(tagInputField.frame.origin.x,tagInputField.frame.origin.y-100,tagInputField.frame.size.width,tagInputField.frame.size.height); 
    
    appleStopTryingToDoStuffWithoutMyPermission = YES; 
}

// totally convoluted function- essentially "textFieldDidChange"
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [tagPredictionViewController queryString:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [tagInputField removeFromSuperview];
    [tagPredictionViewController.view removeFromSuperview];  
    [self retractView];
    return YES;
}

- (void) deleteTagButtonTouched:(NoteTag *)t
{
    
}

- (void) existingTagChosen:(NoteTag *)nt
{
    [self stopEditing];
    if((NSObject *)delegate && [((NSObject *)delegate) respondsToSelector:@selector(noteTagEditorCreatedTag:)]) 
        [delegate noteTagEditorCreatedTag:nt];
}

@end
