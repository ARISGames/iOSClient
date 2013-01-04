//
//  RoundedTableViewCell.m
//  ARIS
//
//  Created by Jacob Hanshaw on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RoundedTableViewCell.h"

#define rad 15

@implementation RoundedTableViewCell
@synthesize topleft;
@synthesize topright;
@synthesize bottomleft;
@synthesize bottomright;
@synthesize bglayer;
@synthesize roundTop;
@synthesize roundBottom;
@synthesize lbl1, lbl2, iconView, lbl4;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forFile:(NSString*)fileName
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if([fileName isEqualToString:@"InventoryTradeViewController.m"]){
            self.frame = CGRectMake(5, 0, 290, 60);
            CGRect IconFrame = CGRectMake(5, 5, 50, 50);
            CGRect Label1Frame = CGRectMake(70, 12, 160, 20); //Title
            CGRect Label2Frame = CGRectMake(70, 29, 220, 20); //Desc
            CGRect Label3Frame = CGRectMake(240, 12, 50, 20); //Qty
            
            //Setup Cell
           // UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
           // transparentBackground.backgroundColor = [UIColor clearColor];
           // self.backgroundView = transparentBackground;
            
            //Initialize Label with tag 1.
            self.lbl1 = [[UILabel alloc] initWithFrame:Label1Frame];
            self.lbl1.tag = 1;
            //lblTemp.textColor = [UIColor whiteColor];
            self.lbl1.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:self.lbl1];
            
            //Initialize Label with tag 2.
            self.lbl2 = [[UILabel alloc] initWithFrame:Label2Frame];
            self.lbl2.tag = 2;
            self.lbl2.font = [UIFont systemFontOfSize:11];
            self.lbl2.textColor = [UIColor darkGrayColor];
            self.lbl2.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:self.lbl2];
            
            //Init Icon with tag 3
            self.iconView = [[AsyncMediaImageView alloc] initWithFrame:IconFrame];
            self.iconView.tag = 3;
            self.iconView.backgroundColor = [UIColor clearColor]; 
            [self.contentView addSubview:self.iconView];
            
            //Init Icon with tag 4
            self.lbl4 = [[UILabel alloc] initWithFrame:Label3Frame];
            self.lbl4.tag = 4;
            //self.lbl4.font = [UIFont boldSystemFontOfSize:11];
            self.lbl4.textColor = [UIColor darkGrayColor];
            self.lbl4.backgroundColor = [UIColor clearColor];
            //lblTemp.textAlignment = UITextAlignmentRight;
            [self.contentView addSubview:self.lbl4];
        }
        
        // initial values
        roundTop = NO;
        roundBottom = NO;

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) drawRect:(CGRect)rect{
    CGRect fr = rect;
    fr.size.width = fr.size.width-2*rad;
    fr.size.height = fr.size.height-1;
    fr.origin.x = rad;
    
    // draw round corners layer
    bglayer = [CALayer layer];
    bglayer.backgroundColor = [UIColor clearColor].CGColor;
    bglayer.cornerRadius = rad;
    bglayer.frame = fr;
    bglayer.zPosition = -5; // important, otherwise delete button does not fire / is covered
    [self.layer addSublayer:bglayer];
    
    // corner layer top left
    topleft = [CALayer layer];
    topleft.backgroundColor = [UIColor clearColor].CGColor;
    CGRect tl = CGRectMake(rad, 0, rad, rad);
    topleft.frame = tl;
    topleft.zPosition = -4;
    if(roundTop){
        topleft.hidden = YES;
    }
    else {
        topleft.hidden = NO;
    }
    [self.layer addSublayer:topleft];
    
    // corner layer top right
    topright = [CALayer layer];
    topright.backgroundColor = [UIColor clearColor].CGColor;
    topright.frame = CGRectMake(fr.size.width, 0, rad, rad);
    topright.zPosition = -3;
    if(roundTop){
        topright.hidden = YES;
    }
    else {
        topright.hidden = NO;
    }
    [self.layer addSublayer:topright];
    
    // corner layer bottom left
    bottomleft = [CALayer layer];
    bottomleft.backgroundColor = [UIColor clearColor].CGColor;
    bottomleft.frame = CGRectMake(rad, fr.size.height-rad, rad, rad);
    bottomleft.zPosition = -2;
    if(roundBottom){
        bottomleft.hidden = YES;
    }
    else {
        bottomleft.hidden = NO;
    }
    [self.layer addSublayer:bottomleft];
    
    // corner layer bottom right
    bottomright = [CALayer layer];
    bottomright.backgroundColor = [UIColor clearColor].CGColor;
    bottomright.frame = CGRectMake(fr.size.width, fr.size.height-rad, rad, rad);
    bottomright.zPosition = -1;
    if(roundBottom){
        bottomright.hidden = YES;
    }
    else {
        bottomright.hidden = NO;
    }
    [self.layer addSublayer:bottomright];

    [super drawRect:rect];
    
}

-(void) drawRoundTop{
    roundTop = YES;
    topleft.hidden = YES;
    topright.hidden = YES;
}

-(void) drawRoundBottom{
    roundBottom = YES;
    bottomleft.hidden = YES;
    bottomright.hidden = YES;
}


@end
