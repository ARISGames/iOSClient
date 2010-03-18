//
//  WaitingIndicatorViewController.h
//  ARIS
//
//  Created by David Gagnon on 5/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingIndicatorViewController : UIViewController {
	UIActivityIndicatorView *spinner;
	UILabel *label;

}

@property(readonly) NSString *message;
-(void) setMessage: (NSString*) newMessage;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, retain) IBOutlet UILabel *label;


@end
