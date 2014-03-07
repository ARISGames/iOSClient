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
    int spacing;
    float rating;
}
@end

@implementation ARISStarView

- (void) setRating:(int)r
{
    rating = r;
    while(self.subviews.count > 0) [[self.subviews objectAtIndex:0] removeFromSuperview];
    
    float sWidth = self.frame.size.width/5;
    UIImageView *s;
    for(int i = 0; i < 5; i++)
    {
        if(i <= r-1) s = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_blue.png"]];
        else         s = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_gray.png"]]; 
        s.frame = CGRectMake(i*sWidth+(spacing*i/5), 0, sWidth-(spacing*4/5), self.frame.size.height); //<- boy I'm clever...
        [self addSubview:s];
    }
}

- (int) rating
{
    return rating;
}

- (void) setSpacing:(int)s
{
    spacing = s;
    [self setRating:rating];//essentially refreshes views 
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setRating:rating];//essentially refreshes views
}

@end
