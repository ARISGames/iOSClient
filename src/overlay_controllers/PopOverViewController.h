//
//  PopOverViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol PopOverViewDelegate
- (void) popOverRequestsDismiss;
- (void) popOverRequestsSubmit;
@end

@interface PopOverViewController : ARISViewController
{
  id<PopOverViewDelegate> __weak delegate;
}

@property (nonatomic, weak) id delegate;

- (id) initWithDelegate:(id <PopOverViewDelegate>)d;
- (void) setHeader:(NSString *)h prompt:(NSString *)p icon_media_id:(long)m;

@end
