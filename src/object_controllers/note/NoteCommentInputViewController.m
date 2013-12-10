//
//  NoteCommentInputViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 12/10/13.
//

#import "NoteCommentInputViewController.h"
#import "UIColor+ARISColors.h"

@interface NoteCommentInputViewController () <UITextViewDelegate>
{
    UITextView *commentArea;
    UIButton *postButton;
    UIButton *cancelButton; 
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
    postButton   = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton addTarget:self action:@selector(postButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    postButton.frame = CGRectMake(self.view.frame.size.width-50, 10, 40, 20);
    postButton.backgroundColor = [UIColor ARISColorDarkBlue];
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    [cancelButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    cancelButton.frame = CGRectMake(self.view.frame.size.width-50, 40, 40, 20); 
    cancelButton.backgroundColor = [UIColor ARISColorDarkBlue]; 
    
    [self.view addSubview:commentArea];
}

- (void) postButtonTouched
{
    [commentArea resignFirstResponder]; 
    [delegate commentConfirmed:commentArea.text];  
}

- (void) cancelButtonTouched
{
    [commentArea resignFirstResponder];  
    [delegate commentCancelled];   
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
