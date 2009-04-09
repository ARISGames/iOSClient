//
//  GenericWebViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/18/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "model/AppModel.h";

@interface GenericWebViewController : UIViewController {
	NSURLRequest *request;
	UIWebView *webview;
	AppModel *appModel;	
	UINavigationItem *backButton;
	UILabel *titleLabel;
}

-(void) setModel:(AppModel *)model;
-(void) setURL:(NSString*)urlString;
-(void) setToolbarTitle:(NSString *)title;
-(void) backButtonAction:(id)sender;


@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UINavigationItem *backButton;


@end
