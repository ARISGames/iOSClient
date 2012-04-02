//
//  UploadingCell.h
//  ARIS
//
//  Created by Brian Thiel on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadingCell : UITableViewCell{
IBOutlet UIProgressView *progressBar;
IBOutlet UILabel *updatingLabel;
}

@property(nonatomic)IBOutlet UIProgressView *progressBar;
@property(nonatomic)IBOutlet UILabel *updatingLabel;
@end
