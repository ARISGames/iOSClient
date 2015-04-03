//
//  NoteTagView.m
//  ARIS
//
//  Created by Phil Dougherty on 1/30/14.
//
//

#import "NoteTagView.h"
#import "Tag.h"

@interface NoteTagView()
{
    Tag *tag;
    BOOL editable;
    id<NoteTagViewDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagView

- (id) initWithNoteTag:(Tag *)nt editable:(BOOL)e delegate:(id<NoteTagViewDelegate>)d
{
    if(self = [super init])
    {
        tag = nt;
        editable = e;
        delegate = d;
        
        long width;
        width = [nt.tag sizeWithAttributes:@{NSFontAttributeName:[ARISTemplate ARISBodyFont]}].width;
        
        self.frame = CGRectMake(0,0,width+30,30);
        self.layer.masksToBounds = YES;

        UILabel *tagText = [[UILabel alloc] initWithFrame:self.bounds];
        [tagText setTextAlignment:NSTextAlignmentCenter];
        tagText.font = [ARISTemplate ARISBodyFont];
        tagText.textColor = [UIColor ARISColorDarkBlue];
        tagText.numberOfLines = 0;
        tagText.text = nt.tag; 
        [self addSubview:tagText];   
        
        if(editable)
        {
            [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iWasTouched)]]; 
            self.userInteractionEnabled = YES;
        }
    }
    return self;
}

- (void) iWasTouched
{
   [delegate noteTagDeleteSelected:tag]; 
}

@end
