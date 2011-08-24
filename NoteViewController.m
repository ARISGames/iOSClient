//
//  NoteViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteViewController.h"
#import "TitleAndDecriptionFormViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "InventoryListViewController.h"
#import "GPSViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "TextViewController.h"

@implementation NoteViewController
@synthesize textBox,textField,note, delegate, hideKeyboardButton,libraryButton,cameraButton,audioButton, typeControl,viewControllers, scrollView,pageControl,publicButton,textButton,mapButton, tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Note";
        self.tabBarItem.image = [UIImage imageNamed:@"noteicon.png"];
        viewControllers = [[NSMutableArray alloc] initWithCapacity:10];
        self.note = [[Note alloc]init];

    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
-(void)viewWillAppear:(BOOL)animated{
    if([self.delegate isKindOfClass:[InventoryListViewController class]]){
        self.note.noteId = [[AppServices sharedAppServices] createNote];
    }
    
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
    //scrollView.pagingEnabled = YES;
    //scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);
    //scrollView.showsHorizontalScrollIndicator = NO;
    //scrollView.showsVerticalScrollIndicator = NO;
    //scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numPages;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouchAction)];      
	self.navigationItem.rightBarButtonItem = saveButton;
    

}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationItem.title = @"Note";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    return YES;
}
-(void)hideKeyboardTouchAction {
    [self.textBox resignFirstResponder];
    self.hideKeyboardButton.hidden = YES;
}
-(void)cameraButtonTouchAction{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    cameraVC.delegate = self.delegate;
    cameraVC.showVid = YES;
    cameraVC.noteId = self.note.noteId;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:cameraVC animated:NO];
    //[cameraVC release];
    [UIView commitAnimations];
}
-(void)audioButtonTouchAction{
    AudioRecorderViewController *audioVC = [[[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil] autorelease];
    audioVC.delegate = self.delegate;
    audioVC.noteId = self.note.noteId;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:audioVC animated:NO];
    //[audioVC release];
    [UIView commitAnimations]; 
}
-(void)libraryButtonTouchAction{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    cameraVC.delegate = self.delegate;
    cameraVC.showVid = NO;
    cameraVC.noteId = self.note.noteId;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:cameraVC animated:NO];
    //[cameraVC release];
    [UIView commitAnimations];
}
-(void)textButtonTouchAction{
    TextViewController *textVC = [[[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil] autorelease];
    textVC.noteId = self.note.noteId;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:textVC animated:NO];
    [UIView commitAnimations];

}

-(void)mapButtonTouchAction{
    
}
-(void)publicButtonTouchAction{
    
}

- (void)displayTitleandDescriptionForm {
    TitleAndDecriptionFormViewController *titleAndDescForm = [[TitleAndDecriptionFormViewController alloc] 
                                                              initWithNibName:@"TitleAndDecriptionFormViewController" bundle:nil];
	
	titleAndDescForm.delegate = self;
	[self.view addSubview:titleAndDescForm.view];
}

- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm{
	NSLog(@"NoteVC: Back from form");
	[titleAndDescForm.view removeFromSuperview];
    if(self.note){
        [[AppServices sharedAppServices] updateItem:self.note];
    }
    else{
        Item *item = [[Item alloc]init];
        item.name = titleAndDescForm.titleField.text;
        item.description = self.textBox.text;
        if([self.delegate isKindOfClass:[GPSViewController class]]){
            [[AppServices sharedAppServices] createItemAndPlaceOnMap:item];
        }
        else [[AppServices sharedAppServices] createItemAndGivetoPlayer:item];
        [item release];
    }
    [titleAndDescForm release];	
    NSString *tab;
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];        
    if ([self.delegate isKindOfClass:[GPSViewController class]]){
        
    }
    else{
    //Exit to Inventory Tab
    for(int i = 0;i < [appDelegate.tabBarController.customizableViewControllers count];i++)
    {
        tab = [[appDelegate.tabBarController.customizableViewControllers objectAtIndex:i] title];
        tab = [tab lowercaseString];
        if([tab isEqualToString:@"inventory"])
        {
            appDelegate.tabBarController.selectedIndex = i;
        }
    }
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}
@end
