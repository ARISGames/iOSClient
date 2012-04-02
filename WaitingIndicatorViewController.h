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

@property(unsafe_unretained) NSString *message;
-(void) setMessage: (NSString*) newMessage;

@property(nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic) IBOutlet UIProgressView *progressView;
@property(nonatomic) IBOutlet UILabel *label;


@end
