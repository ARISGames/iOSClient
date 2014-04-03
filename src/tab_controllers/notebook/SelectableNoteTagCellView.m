//
//  SelectableNoteTagCellView.m
//  ARIS
//
//  Created by Phil Dougherty on 1/28/14.
//
//

#import "SelectableNoteTagCellView.h"
#import "ARISTemplate.h"

@interface SelectableNoteTagCellView()
{
    NoteTag *noteTag;
    id<SelectableNoteTagCellViewDelegate> __unsafe_unretained delegate;
}
@end

@implementation SelectableNoteTagCellView

- (id) initWithFrame:(CGRect)f noteTag:(NoteTag *)nt delegate:(id<SelectableNoteTagCellViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        noteTag = nt;
        delegate = d;
        
        UILabel *tagText = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width, self.frame.size.height-10)];
        tagText.Font = [ARISTemplate ARISButtonFont];
        tagText.text = nt.text;
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
