//
//  WaitingIndicatorAlertView.m
//  ARIS
//
//  Created by David J Gagnon on 9/12/10.
//  Copyright 2010 University of Wisconsin. All rights reserved.
//

#import "WaitingIndicatorAlertView.h"

@implementation WaitingIndicatorAlertView

@synthesize progressView;
@synthesize indicatorView;

- (id)initWithDelegate:(id)delegate
{
    NSLog(@"Initting Waiting View");
	if (self = [super initWithTitle:@"" message:@"" delegate:delegate cancelButtonTitle:nil otherButtonTitles: nil])
    {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.center = CGPointMake(142,73); //Magic numbers... dern it
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicatorView.center = CGPointMake(142,73);//CGPointMake(super.bounds.size.width / 2, super.bounds.size.height - 40); didn't work
	}
	return self;
}

- (void) setWaitingMessage:(NSString *)message showProgressBar:(BOOL)showProgress
{
    if (showProgress)
    {
        [super addSubview:progressView];
    }
    else
    {
        [super addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    }
    
    super.title = message;
}

- (void)show
{
    [super show];
}

- (void)dismiss
{
    [progressView removeFromSuperview];
    [indicatorView stopAnimating];
    [indicatorView removeFromSuperview];
    
	[super dismissWithClickedButtonIndex:0 animated:YES];
}

@end