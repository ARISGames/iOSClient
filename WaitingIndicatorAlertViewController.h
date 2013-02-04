//
//  WaitingIndicatorAlertViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitingIndicatorAlertView.h"

@interface WaitingIndicatorAlertViewController : UIViewController
{
	WaitingIndicatorAlertView *waitingIndicatorAlertView;
}

- (void) displayMessage:(NSString *)message withProgressBar:(BOOL)showProgressBar;
- (void) dismissMessage;

@end