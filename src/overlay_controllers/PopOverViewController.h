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
- (void) popOverContinueButtonPressed;
@end

@interface PopOverViewController : ARISViewController

- (id) initWithDelegate:(id <PopOverViewDelegate,StateControllerProtocol>)poDelegate;
- (void) setTitle:(NSString *)t description:(NSString *)d webViewText:(NSString *)wvt mediaId:(int)m function:(NSString *)f showDismiss:(BOOL)sd;

@end
