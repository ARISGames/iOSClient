//
//  WaitingIndicatorAlertViewController.m
//  ARIS
//
//  Created by David Gagnon on 5/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "WaitingIndicatorAlertViewController.h"

@implementation WaitingIndicatorAlertViewController

- (id) init
{
    NSLog(@"Initting Waiting VC");
	if (self = [super init])
    {
        waitingIndicatorAlertView = [[WaitingIndicatorAlertView alloc] initWithDelegate:self];
	}
	return self;
}

- (void) displayMessage:(NSString *)message withProgressBar:(BOOL)showProgressBar
{
    [waitingIndicatorAlertView setWaitingMessage:message showProgressBar:showProgressBar];
    [waitingIndicatorAlertView show];
}

- (void) dismissMessage
{
    [waitingIndicatorAlertView dismiss];
}

@end