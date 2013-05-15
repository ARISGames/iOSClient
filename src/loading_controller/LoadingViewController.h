//
//  LoadingViewControllerViewController.h
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewControllerDelegate
- (void) loadingViewControllerDidComplete;
@end

@interface LoadingViewController : UIViewController
{
    IBOutlet UIImageView *splashImage;
    IBOutlet UIProgressView *progressBar;
    IBOutlet UILabel *progressLabel;
    int receivedData;
}

@property(nonatomic)IBOutlet UIImageView *splashImage;
@property(nonatomic)IBOutlet UIProgressView *progressBar;
@property(nonatomic)IBOutlet UILabel *progressLabel;
@property(readwrite)int receivedData;

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
- (void)moveProgressBar;

@end
