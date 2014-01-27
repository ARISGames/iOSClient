//
//  NoteCommentInputViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 12/10/13.
//

#import "NoteCommentInputViewController.h"
#import "ARISTemplate.h"

@interface NoteCommentInputViewController () <UITextViewDelegate>
{
    UITextView *commentArea;
    UILabel *postButton;
    UILabel *cancelButton; 
    id<NoteCommentInputViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteCommentInputViewController

- (id) initWithDelegate:(id<NoteCommentInputViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 50);
    commentArea = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
    commentArea.layer.borderWidth = 0.5f;
    commentArea.layer.borderColor = [[UIColor ARISColorDarkGray] CGColor];
    commentArea.delegate = self;
    
    postButton = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-55, 10, 50, 20)];
    postButton.text = @"Post";
    postButton.textColor = [UIColor ARISColorDarkBlue];  
    [postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonTouched)]];
    postButton.userInteractionEnabled = YES; 
    
    cancelButton = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-55, 40, 50, 20)];
    cancelButton.text = @"Don't";
    cancelButton.textColor = [UIColor ARISColorDarkBlue];
    [cancelButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonTouched)]]; 
    cancelButton.userInteractionEnabled = YES;
    
    [self.view addSubview:commentArea];
}

- (void) postButtonTouched
{
    [commentArea resignFirstResponder]; 
    [delegate commentConfirmed:commentArea.text];
    commentArea.text = @"";
}

- (void) cancelButtonTouched
{
    [commentArea resignFirstResponder];  
    [delegate commentCancelled];   
    commentArea.text = @""; 
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 70); 
    commentArea.frame = CGRectMake(10,10,self.view.frame.size.width-20-50,50);
    [self.view addSubview:postButton]; 
    [self.view addSubview:cancelButton];  
    [delegate commentBeganEditing];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 50); 
    commentArea.frame = CGRectMake(10,10,self.view.frame.size.width-20,30); 
    [postButton removeFromSuperview];
    [cancelButton removeFromSuperview]; 
}

@end
