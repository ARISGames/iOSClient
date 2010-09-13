//
//  WaitingIndicatorView.m
//  ARIS
//
//  Created by David J Gagnon on 9/12/10.
//  Copyright 2010 University of Wisconsin. All rights reserved.
//

#import "WaitingIndicatorView.h"


@implementation WaitingIndicatorView

@synthesize progressView;


- (id)initWithWaitingMessage: (NSString*) m showProgressBar:(bool)showProgress {
	if (self = [super initWithTitle:m message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil]) {
		if (showProgress) self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	}
	return self;
}

- (void) setWaitingMessage: (NSString*) newMessage{
	super.title = newMessage;
}

- (NSString*) waitingMessage{
	return super.title;
}

	
- (void)show{
	[super show];
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];	
	indicator.center = CGPointMake(super.bounds.size.width / 2, super.bounds.size.height - 40);
	[indicator startAnimating];
	[super addSubview:indicator];
	[indicator release];
}

- (void)dismiss{
	[super dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)dealloc {
    [super dealloc];
}


@end
