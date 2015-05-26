//
//  LoadingIndicatorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 00/00/15.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol LoadingIndicatorViewDelegate
@end

@interface LoadingIndicatorViewController : ARISViewController

- (id) initWithDelegate:(id <LoadingIndicatorViewDelegate>)d;

@end

