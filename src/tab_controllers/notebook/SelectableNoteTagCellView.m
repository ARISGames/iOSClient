//
//  SelectableNoteTagCellView.m
//  ARIS
//
//  Created by Phil Dougherty on 1/28/14.
//
//

#import "SelectableNoteTagCellView.h"
#import "Tag.h"

@interface SelectableNoteTagCellView()
{
    Tag *noteTag;
    id<SelectableNoteTagCellViewDelegate> __unsafe_unretained delegate;
}
@end

@implementation SelectableNoteTagCellView

- (id) initWithFrame:(CGRect)f noteTag:(Tag *)nt delegate:(id<SelectableNoteTagCellViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        noteTag = nt;
        delegate = d;

        UILabel *tagText = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width, self.frame.size.height-10)];
        tagText.font = [ARISTemplate ARISButtonFont];
        tagText.text = nt.tag;
        [self addSubview:tagText];

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iWasTouched)]];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) iWasTouched
{
   [delegate noteTagSelected:noteTag];
}

@end
