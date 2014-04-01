//
//  NoteTagView.m
//  ARIS
//
//  Created by Phil Dougherty on 1/30/14.
//
//

#import "NoteTagView.h"
#import "ARISTemplate.h"

@interface NoteTagView()
{
    NoteTag *noteTag;
    BOOL editable;
    id<NoteTagViewDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagView

- (id) initWithNoteTag:(NoteTag *)nt editable:(BOOL)e delegate:(id<NoteTagViewDelegate>)d
{
    if(self = [super init])
    {
        noteTag = nt;
        editable = e;
        delegate = d;
        
        int width;
        width = [nt.text sizeWithFont:[ARISTemplate ARISBodyFont]].width;
        
        self.frame = CGRectMake(0,0,width,20);
        //self.backgroundColor = [UIColor ARISColorLightBlue]; 
        //self.layer.cornerRadius = 8;
        //self.layer.masksToBounds = YES;
        
        UILabel *tagText = [[UILabel alloc] initWithFrame:self.bounds];
        tagText.font = [ARISTemplate ARISBodyFont];
        //tagText.textColor = [UIColor whiteColor];
        tagText.text = nt.text; 
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
   [delegate noteTagDeleteSelected:noteTag]; 
}

@end
