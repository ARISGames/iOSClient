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

@interface NodeViewController : UIViewController <UIScrollViewDelegate,UIWebViewDelegate,AsyncMediaImageViewDelegate>
{
	Node *node;
    
    BOOL isLink;
    BOOL hasMedia;
    BOOL imageLoaded;
    BOOL webLoaded;

    UIScrollView *scrollView;
    UIView *mediaArea;
    UIWebView *webView;
    UIButton *continueButton;
    
    AsyncMediaImageView *mediaImageView;
    MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	UIButton *mediaPlaybackButton;
    
    UIActivityIndicatorView *webViewSpinner;
}

@property(readwrite) Node *node;

@property(readwrite, assign) BOOL isLink;
@property(readwrite, assign) BOOL hasMedia;
@property(readwrite, assign) BOOL imageLoaded;
@property(readwrite, assign) BOOL webLoaded;

@property(nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic) UIView *mediaArea;
@property(nonatomic) UIWebView *webView;
@property(nonatomic) UIButton *continueButton;

@property(nonatomic)UIActivityIndicatorView *webViewSpinner;
@property(nonatomic)AsyncMediaImageView *mediaImageView;

@end