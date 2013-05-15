//
//  NodeViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"
#import "Node.h"
#import "ARISMoviePlayerViewController.h"
#import "AsyncMediaImageView.h"

@interface NodeViewController : GameObjectViewController <UIScrollViewDelegate,UIWebViewDelegate,AsyncMediaImageViewDelegate>
{
	Node *node;
}

- (id) initWithNode:(Node *)n delegate:(NSObject<GameObjectViewControllerDelegate> *)d;

@end