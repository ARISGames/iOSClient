//
//  NodeViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Node.h"
#import "ARISMoviePlayerViewController.h"

@interface NodeViewController : UIViewController <UIWebViewDelegate>
{
	Node *node;
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	CGSize imageSize;
	UITableView *tableView;
	UIButton *mediaPlaybackButton;
    UIButton *contineuButton;
	IBOutlet UIScrollView *scrollView;
    IBOutlet UIWebView *aWebView;
    BOOL isLink;
    
}

@property(readwrite, retain) Node *node;
@property(readwrite, assign) BOOL isLink;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIWebView *aWebView;

@property(nonatomic, retain) IBOutlet UIButton *continueButton;

- (void) refreshView;
- (int) calculateTextHeight:(NSString *)text;
@end

