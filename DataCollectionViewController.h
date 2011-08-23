//
//  DataCollectionViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataCollectionViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    id delegate;
    int pageNumber;
    int numPages;
}

@property(nonatomic, retain) id delegate;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property(nonatomic, retain) NSMutableArray *viewControllers;

- (IBAction)saveButtonTouchAction;
-(IBAction)changePage:(id) sender;
- (void)loadNewPageWithView:(NSString *)view;
@end
