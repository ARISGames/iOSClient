//
//  NoteDetailsViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"

@class Note;
@interface NoteDetailsViewController : GameObjectViewController
- (id)initWithNote:(Note *)n delegate:(NSObject<GameObjectViewControllerDelegate> *)d;
@end
