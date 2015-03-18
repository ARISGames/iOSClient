//
//  NoteCommentInputViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 12/10/13.
//

#import "NoteCommentInputViewController.h"

@interface NoteCommentInputViewController () <UITextViewDelegate>
{
    UITextView *commentArea;
    UIImageView *commentPromptImg; 
    UILabel *commentPromptText;
    UILabel *postButton;
    UIImageView *cancelButton; 
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
    commentArea.font = [ARISTemplate ARISInputFont];
    commentArea.delegate = self;
    
    commentPromptImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
    commentPromptImg.image = [UIImage imageNamed:@"speech_bubble.png"];
    commentPromptText = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, 200, 20)];
    commentPromptText.textColor = [UIColor lightGrayColor];
    commentPromptText.font = [ARISTemplate ARISInputFont];
    commentPromptText.text = NSLocalizedString(@"CommentTitleKey", @"");
    
    postButton = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-55, 24, 50, 20)];
    postButton.text = NSLocalizedString(@"PostKey", @"");
    postButton.textColor = [UIColor ARISColorDarkBlue];  
    [postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonTouched)]];
    postButton.userInteractionEnabled = YES; 
    
    cancelButton = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-80, 28, 15, 15)];
    [cancelButton setImage:[UIImage imageNamed:@"discard.png"]];
    [cancelButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonTouched)]]; 
    cancelButton.userInteractionEnabled = YES;
    
    [self.view addSubview:commentArea];
    [self.view addSubview:commentPromptImg]; 
    [self.view addSubview:commentPromptText]; 
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

- (void) dismissKeyboard
{
    [commentArea resignFirstResponder];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 70); 
    commentArea.frame = CGRectMake(10,10,self.view.frame.size.width-20-50,50);
    [self.view addSubview:postButton]; 
    [self.view addSubview:cancelButton];  
    [delegate commentBeganEditing];
    
    [commentPromptImg removeFromSuperview]; 
    [commentPromptText removeFromSuperview];   
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, 50); 
    commentArea.frame = CGRectMake(10,10,self.view.frame.size.width-20,30); 
    [postButton removeFromSuperview];
    [cancelButton removeFromSuperview]; 
    
    [self.view addSubview:commentPromptImg]; 
    [self.view addSubview:commentPromptText];  
}

@end
