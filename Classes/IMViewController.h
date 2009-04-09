//
//  IMViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";

@interface IMViewController : UIViewController {
	NSString *moduleName;
	UIWebView *webview;
	AppModel *appModel;
}

-(void) setModel:(AppModel *)model;

@property(copy, readwrite) NSString *moduleName;
@property (nonatomic, retain) IBOutlet UIWebView *webview;


@end
