//
//  WaitingIndicatorViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingIndicatorViewController : UIViewController {
	UIActivityIndicatorView *spinner;
	UIProgressView *progressView;
	UILabel *label;

}

@property(assign) NSString *message;
-(void) setMessage: (NSString*) newMessage;

@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UIProgressView *progressView;
@property(nonatomic, retain) IBOutlet UILabel *label;


@end
