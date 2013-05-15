//
//  RoundedTableViewCell.h
//  ARIS
//
//  Created by Jacob Hanshaw on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AsyncMediaImageView.h"

@interface RoundedTableViewCell : UITableViewCell{

CALayer* topleft;
CALayer* topright;
CALayer* bottomleft;
CALayer* bottomright;
CALayer* bglayer;
    
BOOL roundTop;
BOOL roundBottom;
    
UILabel *lbl1;
UILabel *lbl2;
AsyncMediaImageView *iconView;
UILabel *lbl4;

}

@property (nonatomic, strong) CALayer* topleft;
@property (nonatomic, strong) CALayer* topright;
@property (nonatomic, strong) CALayer* bottomleft;
@property (nonatomic, strong) CALayer* bottomright;
@property (nonatomic, strong) CALayer* bglayer;

@property (nonatomic) BOOL roundTop;
@property (nonatomic) BOOL roundBottom;

@property (nonatomic, strong) UILabel *lbl1;
@property (nonatomic, strong) UILabel *lbl2;
@property (nonatomic, strong) AsyncMediaImageView *iconView;
@property (nonatomic, strong) UILabel *lbl4;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forFile:(NSString*)fileName;
-(void) drawRoundTop;
-(void) drawRoundBottom;

@end
