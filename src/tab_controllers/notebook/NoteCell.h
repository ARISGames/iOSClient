//
//  NoteCell.h
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import <UIKit/UIKit.h>

@class Note;

@protocol NoteCellDelegate
@end

@interface NoteCell : UITableViewCell
+ (NSString *) cellIdentifier;
- (id) initWithDelegate:(id<NoteCellDelegate>)d;
- (void) populateWithNote:(Note *)n loading:(BOOL)l;
@end
