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
    NSLog(@"Initting Waiting View");
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
    
    //I don't know what this next line does... but it was in the old function. If someone knows what this is and it is redundant, please delete it.
    //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the activity indicator show before returning
}

- (void) dismissMessage
{
    [waitingIndicatorAlertView dismiss];
}

@end