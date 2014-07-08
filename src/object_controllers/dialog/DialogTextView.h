//
//  DialogTextView.h
//  ARIS
//
//  Created by Phil Dougherty on 7/8/14.
//
//

#import <UIKit/UIKit.h>

@protocol DialogTextViewDelegate
- (void) expandedToSize:(CGSize)s;
@end

@interface DialogTextView : UIView

- (id) initWithDelegate:(id<DialogTextViewDelegate>)d;
- (void) loadText:(NSString *)text;
- (void) setOptionsLoading;
- (void) setOptions:(NSArray *)opts;

@end
