//
//  NewUIExampleViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import <UIKit/UIKit.h>

@protocol PopOverViewDelegate
- (void) popOverContinueButtonPressed;
@end

@interface PopOverViewController : UIViewController

- (id) initWithDelegate:(id <PopOverViewDelegate>)poDelegate;
- (void) setTitle:(NSString *)title description:(NSString *)description webViewText:(NSString *)text andMediaId:(int)mediaId;

@end
