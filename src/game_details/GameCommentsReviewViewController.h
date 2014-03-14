//
//  GameCommentsReviewViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/26/14.
//
//

#import "ARISViewController.h"

@class GameComment;
@protocol GameCommentsReviewViewcontrollerDelegate
- (void) reviewCreatedWithRating:(int)r title:(NSString *)t text:(NSString *)s;
@end
@interface GameCommentsReviewViewController : ARISViewController
- (id) initWithDelegate:(id<GameCommentsReviewViewcontrollerDelegate>)d;
@end
