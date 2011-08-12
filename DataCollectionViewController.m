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
@synthesize cameraButton,audioButton,noteButton,videoButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Add Media";
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

-(void)cameraButtonTouchAction{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

-(void)videoButtonTouchAction{
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

-(void)audioButtonTouchAction{
    AudioRecorderViewController *audioVC = [[[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:audioVC animated:YES];
}

-(void)noteButtonTouchAction{
    NoteViewController *noteVC = [[[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:noteVC animated:YES];
}

@end
