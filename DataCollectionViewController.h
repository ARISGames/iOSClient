//
//  DataCollectionViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "NoteContent.h"

@interface DataCollectionViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    id delegate;
    int pageNumber;
    int numPages;
    Note *note;
}

@property(nonatomic, retain) id delegate;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property(nonatomic, retain) NSMutableArray *viewControllers;
@property(nonatomic,retain)Note *note;
- (IBAction)saveButtonTouchAction;
-(IBAction)changePage:(id) sender;
- (void)loadNewPageWithContent:(NoteContent *)content;
@end
