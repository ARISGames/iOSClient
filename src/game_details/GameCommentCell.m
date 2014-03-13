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
#import "ARISTemplate.h"

@interface GameCommentCell () <ARISWebViewDelegate, StateControllerProtocol>
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

- (id) init
{
    if(self = [super init])
    {
        [self initializeViews];
    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initializeViews]; 
    }
    return self;
}

- (void) setDelegate:(id<GameCommentCellDelegate>)d
{
    delegate = d;
}

- (void) initializeViews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    ratingView = [[ARISStarView alloc] init];  
    titleView = [[UILabel alloc] init]; 
    authorView = [[UILabel alloc] init];
    dateView = [[UILabel alloc] init]; 
    commentView = [[ARISWebView alloc] initWithDelegate:self]; 
    
    titleView.font = [ARISTemplate ARISCellTitleFont];
    authorView.font = [ARISTemplate ARISCellSubtextFont];
    authorView.textAlignment = NSTextAlignmentRight;
    dateView.font = [ARISTemplate ARISCellSubtextFont]; 
    dateView.textAlignment = NSTextAlignmentRight; 
    commentView.scrollView.scrollEnabled = NO;
    
    ratingView.frame = CGRectMake(10,10,60,12);
    titleView.frame = CGRectMake(10,0,self.frame.size.width-10,24);
    authorView.frame = CGRectMake(80,10,self.frame.size.width-70-80,15);  
    dateView.frame = CGRectMake(self.frame.size.width-70,10,60,15); 
    commentView.frame = CGRectMake(0, 20, self.frame.size.width, 15);
    
    [self addSubview:ratingView];
    [self addSubview:titleView]; 
    [self addSubview:authorView];
    [self addSubview:dateView];
    [self addSubview:commentView];
}

- (void) setComment:(GameComment *)gc
{
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
    commentView.frame = CGRectMake(0,20,self.frame.size.width,newHeight);
    [delegate heightCalculated:commentView.frame.origin.y+commentView.frame.size.height forComment:gameComment inCell:self];
}

//implement statecontrol stuff for webpage, but ignore any requests
- (void) displayTab:(NSString *)t {}
- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s {return NO;}
- (void) displayScannerWithPrompt:(NSString *)p {}

@end
