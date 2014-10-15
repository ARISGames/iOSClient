//
//  NoteTagPredictionViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 1/27/14.
//
//

#import <UIKit/UIKit.h>

@class Tag;

@protocol NoteTagPredictionViewControllerDelegate
- (void) existingTagChosen:(Tag *)nt;
@end

@interface NoteTagPredictionViewController : UIViewController
- (id) initWithTags:(NSArray *)t delegate:(id<NoteTagPredictionViewControllerDelegate>)d;
- (void) setTags:(NSArray *)t;
- (NSArray *) queryString:(NSString *)qs;
@end
