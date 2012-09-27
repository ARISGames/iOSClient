//
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
        [self setBackgroundImage:inputImage forState:UIControlStateNormal];
        self.titleLabel.text = inputTitle;
        self.titleLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), 0.0f, frame.size.width, frame.size.height);
    self.imageView.frame = frame;
    
    frame = self.titleLabel.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), self.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
    self.titleLabel.frame = frame;
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
