//
//  PopOverViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol StateControllerProtocol;
@protocol PopOverViewDelegate
- (void) popOverRequestsDismiss;
@end

@interface PopOverViewController : ARISViewController

- (id) initWithDelegate:(id <PopOverViewDelegate>)d;
- (void) setHeader:(NSString *)h prompt:(NSString *)p iconMediaId:(int)m;

@end
