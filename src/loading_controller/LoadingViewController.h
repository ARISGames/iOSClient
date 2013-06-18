//
//  LoadingViewControllerViewController.h
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewControllerDelegate
- (void) loadingViewControllerFinishedLoadingGameData;
- (void) loadingViewControllerFinishedLoadingPlayerData;
- (void) loadingViewControllerFinishedLoadingData;
@end

@interface LoadingViewController : UIViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
- (void)moveProgressBar;

@end
