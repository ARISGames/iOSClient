/////
//  IconQuestsButton.m
//  ARIS
//
//  Created by Jacob Hanshaw on 9/25/12.
//
//

#import "IconQuestsButton.h"

@implementation IconQuestsButton

- (id)initWithFrame:(CGRect)inputFrame andImage:(UIImage *) inputImage andTitle:(NSString *) inputTitle
{
    self = [super initWithFrame:inputFrame];
    if (self) {
        self.frame = inputFrame;
        [self setImage:inputImage forState:UIControlStateNormal];
        [self setTitle:inputTitle forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    //CGRect frame = self.imageView.frame;
    CGRect imageFrame = CGRectMake(0, 0, self.frame.size.width, (self.frame.size.height-15));
    self.imageView.frame = imageFrame;
    
    //frame = self.titleLabel.frame;
    CGRect textFrame = CGRectMake(0, (self.frame.size.height-10), self.frame.size.width, 10);
    self.titleLabel.frame = textFrame;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
