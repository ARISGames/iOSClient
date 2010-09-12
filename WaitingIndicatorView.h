//
//  WaitingIndicatorView.h
//  ARIS
//
//  Created by David J Gagnon on 9/12/10.
//  Copyright 2010 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingIndicatorView : UIView {
	UIAlertView *alertView;
	UIProgressView *progressView;
}

@property (nonatomic, retain) UIAlertView *alertView;
@property(assign) NSString *message;
-(void) setMessage: (NSString*) newMessage;
@property(nonatomic, retain) UIProgressView *progressView;

- (id)initWithMessage: (NSString*)m showProgressBar:(bool)showProgress;
- (void)show;
- (void)dismiss;


@end
