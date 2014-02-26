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
        self.title = @"Write a Review";
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    rateView.rating = 0;
    
    commentArea = [[UITextView alloc] init];
    commentArea.font = [ARISTemplate ARISInputFont];
    commentArea.delegate = self;
    
    postButton = [[UILabel alloc] init];
    postButton.text = @"Post";
    postButton.textColor = [UIColor ARISColorDarkBlue];  
    [postButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonTouched)]];
    postButton.userInteractionEnabled = YES; 
    
    [self.view addSubview:rateView]; 
    [self.view addSubview:commentArea];
    [self.view addSubview:postButton];
    
    [self.view addSubview:rate1];
    [self.view addSubview:rate2]; 
    [self.view addSubview:rate3]; 
    [self.view addSubview:rate4]; 
    [self.view addSubview:rate5]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    rateView.frame = CGRectMake(10, 74, self.view.frame.size.width-20, 50);
    commentArea.frame = CGRectMake(0, 134, self.view.frame.size.width, 100);
    postButton.frame = CGRectMake(self.view.frame.size.width-55, self.view.frame.size.height-300, 50, 20);
    
    float starWidth = (self.view.frame.size.width-20)/5;
    rate1.frame = CGRectMake(10+(0*starWidth),74,starWidth,50);
    rate2.frame = CGRectMake(10+(1*starWidth),74,starWidth,50); 
    rate3.frame = CGRectMake(10+(2*starWidth),74,starWidth,50); 
    rate4.frame = CGRectMake(10+(3*starWidth),74,starWidth,50); 
    rate5.frame = CGRectMake(10+(4*starWidth),74,starWidth,50); 
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

//haaaaaccckkkk
- (void) rateOneStar   { rateView.rating = 1; }
- (void) rateTwoStar   { rateView.rating = 2; }
- (void) rateThreeStar { rateView.rating = 3; }
- (void) rateFourStar  { rateView.rating = 4; }
- (void) rateFiveStar  { rateView.rating = 5; }

@end
