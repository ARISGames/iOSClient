//
//  WaitingIndicatorAlertView.h
//  ARIS
//
//  Created by David J Gagnon on 9/12/10.
//  Copyright 2010 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitingIndicatorAlertView : UIAlertView {
	UIProgressView *progressView;
	UIActivityIndicatorView *indicatorView;
}

@property(nonatomic) UIProgressView *progressView;
@property(nonatomic) UIActivityIndicatorView *indicatorView;

- (id) initWithDelegate:(id)delegate;
- (void) setWaitingMessage:(NSString *)message showProgressBar:(BOOL)showProgress;
- (void) show;
- (void) dismiss;

@end