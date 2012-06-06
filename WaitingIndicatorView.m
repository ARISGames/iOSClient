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


- (id)initWithWaitingMessage: (NSString*) m showProgressBar:(BOOL)showProgress {
	if (self = [super initWithTitle:m message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil]) {
		if (showProgress){ 
            UIProgressView *progressViewAlloc = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            self.progressView = progressViewAlloc;
        }
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
	
    if (progressView) {
        [super addSubview:progressView];
        progressView.center = CGPointMake(142,73);
    }
    else{
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];	
        [indicator startAnimating];
        [super addSubview:indicator];
        indicator.center = CGPointMake(142,73);//CGPointMake(super.bounds.size.width / 2, super.bounds.size.height - 40); didn't work
        NSLog(@"WaitingIndicatorView: show: center at %f, %f", indicator.center.x, indicator.center.y );
    }
}

- (void)dismiss{
	[super dismissWithClickedButtonIndex:0 animated:YES];
}



@end
