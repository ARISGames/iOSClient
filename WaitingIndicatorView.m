//
//  WaitingIndicatorView.m
//  ARIS
//
//  Created by David J Gagnon on 9/12/10.
//  Copyright 2010 University of Wisconsin. All rights reserved.
//

#import "WaitingIndicatorView.h"


@implementation WaitingIndicatorView

@synthesize alertView, message, progressView;

- (id)initWithMessage: (NSString*) m showProgressBar:(bool)showProgress {
	if (self = [super init]) {
		self.alertView = [[[UIAlertView alloc] initWithTitle:m message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
	}
	return self;
}
	
	



- (void) setMessage: (NSString*) newMessage{
	self.alertView.title = newMessage;
}

- (NSString*) message{
	return self.alertView.title;
}

- (void)show{
	[self.alertView show];
	
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];	
	indicator.center = CGPointMake(self.alertView.bounds.size.width / 2, self.alertView.bounds.size.height - 50);
	[indicator startAnimating];
	[self.alertView addSubview:indicator];
	[indicator release];
}

- (void)dismiss{
	[self.alertView dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)dealloc {
    [super dealloc];
}


@end
