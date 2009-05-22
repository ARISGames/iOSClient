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

@interface NodeViewController : UIViewController 
{
	AppModel *appModel;
	Node *node;
	
	UITableView *tableView;
	UIWebView *webView;
}

@property(readwrite, retain) AppModel *appModel;
@property(readwrite, retain) Node *node;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIWebView *webView;

- (void) refreshView;
@end

