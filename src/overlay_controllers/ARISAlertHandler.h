//
//  ARISAlertHandler.h
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import <UIKit/UIKit.h>

@interface ARISAlertHandler : NSObject

+ (ARISAlertHandler *) sharedAlertHandler;

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void) showServerAlertEmailWithTitle:(NSString *)title message:(NSString *)message details:(NSString*)detail;

- (void) showWaitingIndicator:(NSString *)message;;
- (void) removeWaitingIndicator;

- (void) showNetworkAlert;
- (void) removeNetworkAlert;

@end
