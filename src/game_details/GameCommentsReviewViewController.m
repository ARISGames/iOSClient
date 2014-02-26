//
//  GameCommentsReviewViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/26/14.
//
//

#import "GameCommentsReviewViewController.h"
#import "GameComment.h"
#import "ARISStarView.h"
#import "ARISTemplate.h"

@interface GameCommentsReviewViewController () <UITextViewDelegate>
{
    ARISStarView *rateView;
    UITextView *commentArea;
    UIImageView *commentPromptImg; 
    UILabel *commentPromptText;
    UILabel *postButton;
    id<GameCommentsReviewViewcontrollerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GameCommentsReviewViewController

- (id) initWithDelegate:(id<GameCommentsReviewViewcontrollerDelegate>)d
{
    if(self = [super init])
    {
        self.title = @"Write a Review";
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    rateView = [[ARISStarView alloc] init];
    rateView.rating = 0;
    
    commentArea = [[UITextView alloc] init];
    commentArea.font = [ARISTemplate ARISInputFont];
    commentArea.delegate = self;
    
    commentPromptImg = [[UIImageView alloc] init];
    commentPromptImg.image = [UIImage imageNamed:@"comment.png"];
    commentPromptText = [[UILabel alloc] init];
    commentPromptText.textColor = [UIColor lightGrayColor];
    commentPromptText.font = [ARISTemplate ARISInputFont];
    commentPromptText.text = @"Comment";
    
    postButton = [[UILabel alloc] init];
    postButton.text = @"Post";
    postButton.textColor = [UIColor ARISColorDarkBlue];  
    [postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonTouched)]];
    postButton.userInteractionEnabled = YES; 
    
    [self.view addSubview:rateView]; 
    [self.view addSubview:commentArea];
    [self.view addSubview:commentPromptImg]; 
    [self.view addSubview:commentPromptText]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    rateView.frame = CGRectMake(10, 74, self.view.frame.size.width-20, 50);
    commentArea.frame = CGRectMake(0, 134, self.view.frame.size.width, 100);
    commentPromptImg.frame = CGRectMake(15, 15, 20, 20);
    commentPromptText.frame = CGRectMake(40, 15, 200, 20);
    postButton.frame = CGRectMake(self.view.frame.size.width-55, 10, 50, 20);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [commentArea becomeFirstResponder];
}

- (void) postButtonTouched
{
    [commentArea resignFirstResponder]; 
    [delegate reviewCreatedWithRating:rateView.rating text:commentArea.text];
    commentArea.text = @"";
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [self.view addSubview:postButton]; 
    
    [commentPromptImg removeFromSuperview]; 
    [commentPromptText removeFromSuperview];   
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    [postButton removeFromSuperview];
    
    [self.view addSubview:commentPromptImg]; 
    [self.view addSubview:commentPromptText];  
}

@end
