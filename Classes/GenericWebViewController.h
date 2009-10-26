//
//  GenericWebViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/18/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";

@interface GenericWebViewController : UIViewController <UIWebViewDelegate> {
	NSURLRequest *request;
	UIWebView *webview;
	AppModel *appModel;	
}

-(void) setModel:(AppModel *)model;
-(void) setURL:(NSString*)urlString;



@property (nonatomic, retain) IBOutlet UIWebView *webview;



@end
