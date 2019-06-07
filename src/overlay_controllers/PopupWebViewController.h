//
//  PopupWebViewController.h
//  ARIS
//
//  Created by Michael Tolly on 6/6/19.
//

#ifndef PopupWebViewController_h
#define PopupWebViewController_h

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"

@protocol PopupWebViewControllerDelegate
- (void) popupRequestsDismiss;
@end

@interface PopupWebViewController : ARISViewController
- (id) initWithContent:(NSString *)s delegate:(id<PopupWebViewControllerDelegate>)d;
@end

#endif /* PopupWebViewController_h */
