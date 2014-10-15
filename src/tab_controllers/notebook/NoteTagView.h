//
//  NoteTagView.h
//  ARIS
//
//  Created by Phil Dougherty on 1/30/14.
//
//

#import <UIKit/UIKit.h>

@class Tag;

@protocol NoteTagViewDelegate
- (void) noteTagDeleteSelected:(Tag *)nt;
@end

@interface NoteTagView : UIView
- (id) initWithNoteTag:(Tag *)nt editable:(BOOL)e delegate:(id<NoteTagViewDelegate>)d;
@end
