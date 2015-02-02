//
//  DialogTextView.h
//  ARIS
//
//  Created by Phil Dougherty on 7/8/14.
//
//

#import <UIKit/UIKit.h>
@class DialogTextView;
@protocol DialogTextViewDelegate
- (void) dialogTextView:(DialogTextView *)dtv expandedToSize:(CGSize)s;
- (void) dialogTextView:(DialogTextView *)dtv selectedOption:(long)o;
@end

@interface DialogTextView : UIView
- (id) initWithDelegate:(id<DialogTextViewDelegate>)d;
- (void) loadText:(NSString *)text;
- (void) setOptionsLoading;
- (void) setOptions:(NSArray *)opts;
@end
