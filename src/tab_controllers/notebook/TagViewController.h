//
//  TagViewController.h
//  ARIS
//
//  Created by Brian Thiel on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

#import "Note.h"

@interface TagViewController : ARISViewController
- (id) initWithNote:(Note *)n;
@end
