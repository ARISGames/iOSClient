//
//  ConversationController.h
//  ARIS
//
//  Created by Kevin Harris on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NPC;

@interface ConversationController : UIViewController {
	UITableView *tableView;
	UIWebView *webView;
	UIImageView *imageView;
	NSMutableArray *options;
	NPC *npc;
}

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(readwrite, retain) NSMutableArray *options;
@property(readwrite, retain) NPC *npc;

@end
