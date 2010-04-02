//
//  NodeViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Node.h"
#import <MediaPlayer/MediaPlayer.h>


@interface NodeViewController : UIViewController 
{
	AppModel *appModel;
	Node *node;
	MPMoviePlayerController *mMoviePlayer; //only used if item is a video

	UITableView *tableView;
	IBOutlet UIScrollView *scrollView;
}

@property(readwrite, retain) AppModel *appModel;
@property(readwrite, retain) Node *node;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (void) refreshView;
- (int) calculateTextHeight:(NSString *)text;

@end

