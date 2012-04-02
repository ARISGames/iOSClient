//
//  WaitingIndicatorView.h
//  ARIS
//
//  Created by David J Gagnon on 9/12/10.
//  Copyright 2010 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingIndicatorView : UIAlertView {
	UIProgressView *progressView;
}

@property(nonatomic) UIProgressView *progressView;
@property(nonatomic, copy) NSString *waitingMessage;

-(void) setWaitingMessage: (NSString*) newMessage;

- (id)initWithWaitingMessage: (NSString*)m showProgressBar:(BOOL)showProgress;
- (void)show;
- (void)dismiss;


@end
