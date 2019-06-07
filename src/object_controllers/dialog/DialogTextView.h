//
//  DialogTextView.h
//  ARIS
//
//  Created by Phil Dougherty on 7/8/14.
//
//

#import <UIKit/UIKit.h>
@class DialogTextView;
@protocol DialogTextViewDelegate <NSObject>
- (void) dialogTextView:(DialogTextView *)dtv expandedToSize:(CGSize)s;
- (void) dialogTextView:(DialogTextView *)dtv selectedOption:(long)o;
- (void) popupWithContent:(NSString *)s;
@end

@interface DialogTextView : UIView
- (id) initWithDelegate:(id<DialogTextViewDelegate>)d;
- (void) loadText:(NSString *)text;
- (void) setOptionsLoading;
- (void) setOptions:(NSArray *)opts;
@end
