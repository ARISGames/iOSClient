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
- (void) dialogTextView:(DialogTextView *)dtv selectedOption:(int)o;
@end

@protocol StateControllerProtocol;
@interface DialogTextView : UIView
- (id) initWithDelegate:(id<DialogTextViewDelegate, StateControllerProtocol>)d;
- (void) loadText:(NSString *)text;
- (void) setOptionsLoading;
- (void) setOptions:(NSArray *)opts;
@end
