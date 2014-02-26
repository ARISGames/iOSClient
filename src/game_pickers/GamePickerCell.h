//
//  GamePickerCell.h
//  ARIS
//
//  Created by David J Gagnon on 2/19/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;

@interface GamePickerCell : UITableViewCell
- (void) setGame:(Game *)g;
- (void) setCustomLabelText:(NSString *)t;
@end
