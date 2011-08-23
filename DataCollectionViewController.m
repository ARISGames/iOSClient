//
//  DataCollectionViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataCollectionViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "NoteViewController.h"

@implementation DataCollectionViewController
@synthesize scrollView,pageControl, delegate, viewControllers;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Add Media";
        viewControllers = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    //scrollView.showsVerticalScrollIndicator = NO;
    //scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numPages;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouchAction)];      
	self.navigationItem.rightBarButtonItem = saveButton;

}
-(void)viewWillAppear:(BOOL)animated{
    [self loadNewPageWithView:@"note"];
   // [self loadNewPageWithView:@"photo"];
    [self loadNewPageWithView:@"audio"];

}

- (void)scrollViewDidScroll:(UIScrollView *)sender {

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    pageControl.numberOfPages = numPages;
    
   }

-(void)saveButtonTouchAction{
   //[self displayTitleandDescriptionForm];
}
- (void)loadNewPageWithView:(NSString *)view {

    numPages++;
    scrollView.contentSize = CGSizeMake(320 * numPages, scrollView.frame.size.height);
    pageControl.numberOfPages = numPages;
    if([view isEqualToString:@"note"]){
      NoteViewController *controller = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
        controller.delegate = self.delegate;
        [viewControllers addObject:controller];
        [controller release];
        if (nil == controller.view.superview) {
            CGRect frame = scrollView.frame;
            frame.origin.x = frame.size.width * (numPages-1);
            frame.origin.y = 0;
            controller.view.frame = frame;
            [scrollView addSubview:controller.view];}
    }
    else if([view isEqualToString:@"photo"]){
            CameraViewController *controller = [[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil];
        controller.delegate = self.delegate;
            [viewControllers addObject:controller];
            [controller release];
            if (nil == controller.view.superview) {
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * (numPages-1);
                frame.origin.y = 0;
                controller.view.frame = frame;
                [scrollView addSubview:controller.view];}
        }
        else if([view isEqualToString:@"audio"]){
                AudioRecorderViewController *controller = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
            controller.delegate = self.delegate;
                [viewControllers addObject:controller];
                [controller release];
                if (nil == controller.view.superview) {
                    CGRect frame = scrollView.frame;
                    frame.origin.x = frame.size.width * (numPages-1);
                    frame.origin.y = 0;
                    controller.view.frame = frame;
                    [scrollView addSubview:controller.view];
                }
        }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)changePage:(id)sender{
    
}

@end
