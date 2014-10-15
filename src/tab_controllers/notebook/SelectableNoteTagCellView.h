//
//  SelectableNoteTagCellView.h
//  ARIS
//
//  Created by Phil Dougherty on 1/28/14.
//
//

#import <UIKit/UIKit.h>

@class Tag;

@protocol SelectableNoteTagCellViewDelegate
- (void) noteTagSelected:(Tag *)nt;
@end
@interface SelectableNoteTagCellView : UIView
- (id) initWithFrame:(CGRect)f noteTag:(Tag *)nt delegate:(id<SelectableNoteTagCellViewDelegate>)d;
@end
