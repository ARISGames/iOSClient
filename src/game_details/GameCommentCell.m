//
//  GameCommentCell.m
//  ARIS
//
//  Created by Philip Dougherty on 6/7/11.
//  Copyright 2011 UW Madison. All rights reserved.
//

#import "GameCommentCell.h"
#import "GameComment.h"
#import "ARISWebView.h"
#import "ARISStarView.h"

@interface GameCommentCell () <ARISWebViewDelegate>
{
    ARISStarView *ratingView; 
   	UILabel *titleView; 
	UILabel *authorView;
   	UILabel *dateView; 
   	ARISWebView *commentView; 
    
    GameComment *gameComment;
    id<GameCommentCellDelegate> __unsafe_unretained delegate;
}
@end

@implementation GameCommentCell

- (void) setDelegate:(id<GameCommentCellDelegate>)d
{
    delegate = d;
}

- (void) initViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone; 
    
    titleView = [[UILabel alloc] init]; 
    ratingView = [[ARISStarView alloc] init];   
    authorView = [[UILabel alloc] init];
    dateView = [[UILabel alloc] init]; 
    commentView = [[ARISWebView alloc] initWithDelegate:self]; 
    
    titleView.font = [ARISTemplate ARISCellTitleFont];
    authorView.font = [ARISTemplate ARISCellSubtextFont];
    authorView.textAlignment = NSTextAlignmentRight;
    dateView.font = [ARISTemplate ARISCellSubtextFont]; 
    dateView.textAlignment = NSTextAlignmentRight; 
    commentView.scrollView.scrollEnabled = NO; 
    
    [self.contentView addSubview:ratingView];
    [self.contentView addSubview:titleView]; 
    [self.contentView addSubview:authorView];
    [self.contentView addSubview:dateView];
    [self.contentView addSubview:commentView]; 
}

- (void) layoutViews:(BOOL)hasTitle
{
    if(!titleView) [self initViews];
    
    titleView.frame = CGRectMake(10,5,self.frame.size.width-10,24); 
    long offset = 0;
    if(hasTitle) offset = 20; 
    ratingView.frame = CGRectMake(10,10+offset,60,12);
    authorView.frame = CGRectMake(80,10+offset,self.frame.size.width-70-80,15);  
    dateView.frame = CGRectMake(self.frame.size.width-70,10+offset,60,15);  
    commentView.frame = CGRectMake(0, 20+offset, self.frame.size.width, 15);
}

- (void) setComment:(GameComment *)gc
{
    [self layoutViews:![titleView.text isEqualToString:@""]];
    gameComment = gc;
    ratingView.rating = gc.rating;
    titleView.text = gc.title; 
    authorView.text = gc.playerName;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    dateView.text = [format stringFromDate:gc.date]; 
    
    [commentView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], gc.text] baseURL:nil]; 
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    float newHeight = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]; 
    commentView.frame = CGRectMake(0,20+([titleView.text isEqualToString:@""] ? 0 : 20),self.frame.size.width,newHeight);
    [delegate heightCalculated:commentView.frame.origin.y+commentView.frame.size.height forComment:gameComment inCell:self];
}

@end
