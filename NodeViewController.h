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

@interface NodeViewController : UIViewController 
{
	Node *node;
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	CGSize imageSize;
	UITableView *tableView;
	UIButton *mediaPlaybackButton;
    UIButton *contineuButton;
	IBOutlet UIScrollView *scrollView;
    
}

@property(readwrite, retain) Node *node;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIButton *continueButton;

- (void) refreshView;
- (int) calculateTextHeight:(NSString *)text;
@end

