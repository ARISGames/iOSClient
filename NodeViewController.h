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
#import "AsyncMediaImageView.h"

@interface NodeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,  AsyncMediaImageViewDelegate>
{
	Node *node;
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	UITableView *tableView;
	UIButton *mediaPlaybackButton;
    BOOL isLink;
    BOOL hasMedia;
    BOOL imageLoaded, webLoaded;
    
    AsyncMediaImageView *mediaImageView;
    UIActivityIndicatorView *webViewSpinner;
    NSArray *cellArray;
}

@property(readwrite) Node *node;
@property(readwrite, assign) BOOL isLink;
@property(readwrite, assign) BOOL hasMedia;
@property(nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic)UIActivityIndicatorView *webViewSpinner;
@property(nonatomic)AsyncMediaImageView *mediaImageView;
@property(nonatomic)NSArray *cellArray;

@end

