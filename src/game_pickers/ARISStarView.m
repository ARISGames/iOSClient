//
//  ARISStarView.m
//  ARIS
//
//  Created by Phil Dougherty on 2/26/14.
//
//

#import "ARISStarView.h"

@interface ARISStarView ()
{
    float rating;
}
@end

@implementation ARISStarView

- (void) setRating:(int)r
{
    while(self.subviews.count > 0) [[self.subviews objectAtIndex:0] removeFromSuperview];
    
    float sWidth = self.frame.size.width/5;
    UIImageView *s;
    for(int i = 0; i < 5; i++)
    {
        if(i <= r-1) s = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_blue.png"]];
        else       s = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_gray.png"]]; 
        s.frame = CGRectMake(i*sWidth, 0, sWidth, self.frame.size.height);
        [self addSubview:s];
    }
}

- (int) rating
{
    return rating;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setRating:rating];//essentially refreshes views
}

@end
