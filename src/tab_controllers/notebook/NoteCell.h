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

- (void) populateWithNote:(Note *)n;
- (void) setTitle:(NSString *)t;
- (void) setDate:(NSString *)d;
- (void) setOwner:(NSString *)o;
- (void) setDescription:(NSString *)d;
- (void) setHasImageIcon:(BOOL)i;
- (void) setHasVideoIcon:(BOOL)v;
- (void) setHasAudioIcon:(BOOL)a;

@end
