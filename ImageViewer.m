//
//  ImageViewer.m
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewer.h"


@implementation ImageViewer
@synthesize imageView,media;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    //    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    //    [dispatcher addObserver:self selector:@selector(updateImage) name:@"ImageReady" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(imageView)
    [imageView release];
    if(media)
    [media release];
}
-(void)updateImage{
//    self.imageView.image = [UIImage imageWithData: self.media.image];
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
    [self.imageView loadImageFromMedia:self.media];
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

@end
