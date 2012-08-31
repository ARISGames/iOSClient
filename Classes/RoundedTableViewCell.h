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

@property (nonatomic, retain) CALayer* topleft;
@property (nonatomic, retain) CALayer* topright;
@property (nonatomic, retain) CALayer* bottomleft;
@property (nonatomic, retain) CALayer* bottomright;
@property (nonatomic, retain) CALayer* bglayer;

@property (nonatomic) BOOL roundTop;
@property (nonatomic) BOOL roundBottom;

@property (nonatomic, retain) UILabel *lbl1;
@property (nonatomic, retain) UILabel *lbl2;
@property (nonatomic, retain) AsyncMediaImageView *iconView;
@property (nonatomic, retain) UILabel *lbl4;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forFile:(NSString*)fileName;
-(void) drawRoundTop;
-(void) drawRoundBottom;

@end
