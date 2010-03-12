//
//  NodeViewController.h
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Npc.h"

@interface NpcViewController : UIViewController 
{
	AppModel *appModel;
	Npc *npc;
	
	UITableView *tableView;
	IBOutlet UIScrollView *scrollView;
}

@property(readwrite, retain) AppModel *appModel;
@property(readwrite, retain) Npc *npc;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (void) refreshView;
- (int) calculateTextHeight:(NSString *)text;

@end

