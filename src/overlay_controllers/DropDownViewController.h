//
//  DropDownViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@protocol DropDownViewDelegate
- (void) dropDownRequestsDismiss;
@end

@interface DropDownViewController : ARISViewController
{
  id<DropDownViewDelegate> __weak delegate;
}

@property (nonatomic, weak) id delegate;

- (id) initWithDelegate:(id <DropDownViewDelegate>)d;
- (void) setString:(NSString *)s;

@end
