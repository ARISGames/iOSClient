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

@interface GameCommentsReviewViewController () <UITextViewDelegate, UITextFieldDelegate>
{
    UILabel *ratePrompt;  
    ARISStarView *rateView;
    UILabel *commentPrompt; 
    UITextField *titleField; 
    UITextView *commentArea;
    UILabel *postButton;
    
    UIButton *rate1;
    UIButton *rate2; 
    UIButton *rate3; 
    UIButton *rate4; 
    UIButton *rate5; 
    
    id<GameCommentsReviewViewcontrollerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GameCommentsReviewViewController

- (id) initWithDelegate:(id<GameCommentsReviewViewcontrollerDelegate>)d
{
    if(self = [super init])
    {
        self.title = NSLocalizedString(@"WriteReviewKey", @"");
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    ratePrompt = [[UILabel alloc] init];
    ratePrompt.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"RatingPromptKey", @"")];
    ratePrompt.font = [ARISTemplate ARISCellSubtextFont]; 
    ratePrompt.textAlignment = NSTextAlignmentCenter;
    ratePrompt.textColor = [UIColor ARISColorDarkGray]; 
    
    //Holy hack. This is hilarious. But at least it's contained.
    rate1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rate1 addTarget:self action:@selector(rateOneStar) forControlEvents:UIControlEventTouchDown];
    rate2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rate2 addTarget:self action:@selector(rateTwoStar) forControlEvents:UIControlEventTouchDown]; 
    rate3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rate3 addTarget:self action:@selector(rateThreeStar) forControlEvents:UIControlEventTouchDown]; 
    rate4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rate4 addTarget:self action:@selector(rateFourStar) forControlEvents:UIControlEventTouchDown]; 
    rate5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rate5 addTarget:self action:@selector(rateFiveStar) forControlEvents:UIControlEventTouchDown]; 
    
    rateView = [[ARISStarView alloc] init];
    rateView.spacing = 30;
    rateView.rating = 0;
    
    titleField = [[UITextField alloc] init];
    titleField.font = [ARISTemplate ARISInputFont];
    titleField.placeholder = NSLocalizedString(@"TitleAndDescriptionTitleKey", @"");
    titleField.returnKeyType = UIReturnKeyDone;
    titleField.delegate = self;
    
    commentPrompt = [[UILabel alloc] init];
    commentPrompt.text = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"WriteReviewKey", @""), NSLocalizedString(@"OptionalKey", @"")];
    commentPrompt.font = [ARISTemplate ARISBodyFont];  
    commentPrompt.textColor = [UIColor ARISColorDarkGray];
    
    commentArea = [[UITextView alloc] init];
    commentArea.font = [ARISTemplate ARISInputFont];
    commentArea.delegate = self;
    
    postButton = [[UILabel alloc] init];
    postButton.text = NSLocalizedString(@"PostKey", @"");
    postButton.textColor = [UIColor ARISColorDarkBlue];  
    [postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonTouched)]];
    postButton.userInteractionEnabled = YES; 
    
    [self.view addSubview:rateView];  
    [self.view addSubview:ratePrompt];   
    [self.view addSubview:titleField];
    [self.view addSubview:commentArea]; 
    [self.view addSubview:commentPrompt];  
    
    [self.view addSubview:rate1];
    [self.view addSubview:rate2]; 
    [self.view addSubview:rate3]; 
    [self.view addSubview:rate4]; 
    [self.view addSubview:rate5]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    ratePrompt.frame = CGRectMake(20,110,self.view.frame.size.width-40,20);
    rateView.frame = CGRectMake(20, 74, self.view.frame.size.width-40, 30);
    titleField.frame = CGRectMake(10, 134, self.view.frame.size.width-20, 20); 
    commentPrompt.frame = CGRectMake(10,160,self.view.frame.size.width-40,20);    
    commentArea.frame = CGRectMake(0, 154, self.view.frame.size.width, 100);
    postButton.frame = CGRectMake(0, 0, 40, 27); 
    
    float starWidth = (self.view.frame.size.width-20)/5;
    rate1.frame = CGRectMake(10+(0*starWidth),74,starWidth,50);
    rate2.frame = CGRectMake(10+(1*starWidth),74,starWidth,50); 
    rate3.frame = CGRectMake(10+(2*starWidth),74,starWidth,50); 
    rate4.frame = CGRectMake(10+(3*starWidth),74,starWidth,50); 
    rate5.frame = CGRectMake(10+(4*starWidth),74,starWidth,50); 
       
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];  
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [titleField becomeFirstResponder];
}

- (void) postButtonTouched
{
    [titleField resignFirstResponder];   
    [commentArea resignFirstResponder]; 
    [delegate reviewCreatedWithRating:rateView.rating title:titleField.text text:commentArea.text];
    titleField.text = @"";
    commentArea.text = @""; 
}

- (void) textViewDidChange:(UITextView *)textView
{
    commentPrompt.hidden = YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [titleField resignFirstResponder];
    return NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [commentArea becomeFirstResponder];
}

- (void) backButtonTouched
{
    [self.navigationController popViewControllerAnimated:YES];
}

//haaaaaccckkkk
- (void) rateOneStar   { rateView.rating = 1; }
- (void) rateTwoStar   { rateView.rating = 2; }
- (void) rateThreeStar { rateView.rating = 3; }
- (void) rateFourStar  { rateView.rating = 4; }
- (void) rateFiveStar  { rateView.rating = 5; }

@end
