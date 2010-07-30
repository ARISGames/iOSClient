//
//  AsyncImageView.m
//  ARIS
//
//  Created by David J Gagnon on 11/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "AsyncImageView.h"


@implementation AsyncImageView

- (void)loadImageFromMedia:(Media *) aMedia {
	media = aMedia;
	
	//check if the media already as the image, if so, just grab it
	if (media.image) {
		[self updateViewWithNewImage:media.image];
		return;
	}
	
	//set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//put a spinner in the view
	UIActivityIndicatorView *spinner = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[spinner startAnimating];
	
	spinner.center = self.center;
	[self addSubview:spinner];
	
	if (connection!=nil) { [connection release]; }
    if (data!=nil) { [data release]; }
    NSURLRequest* request = [NSURLRequest requestWithURL:[[NSURL alloc]initWithString:media.url]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
		data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//end the UI indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//throw out the connection
    [connection release];
    connection=nil;
	
	//turn the data into an image
	UIImage* image = [UIImage imageWithData:data];
	
	//throw out the data
	[data release];
    data=nil;
	
	//Save the image in the media
	media.image = image;
	[media.image retain];
	
	[self updateViewWithNewImage:image];
}

- (void) updateViewWithNewImage:(UIImage*)image {
	[UIView beginAnimations:@"async" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.1];
	self.alpha = 0;
	[UIView commitAnimations];
	
	//clear out the subviews
    while ([[self subviews] count] > 0) {
		[[[self subviews] lastObject] removeFromSuperview];
    }
		
	//create the image view
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
	
    imageView.contentMode = UIViewContentModeScaleAspectFit;
	
    [self addSubview:imageView];
    imageView.frame = self.bounds;
	
	NSLog(@"AsyncImageView: image frame is X:%f Y:%f Width:%f Height:%f",imageView.frame.origin.x,imageView.frame.origin.y,imageView.frame.size.width,imageView.frame.size.height );

	
    [imageView setNeedsLayout];
    [self setNeedsLayout];
	[self.superview setNeedsLayout];

	[UIView beginAnimations:@"async" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25];
	self.alpha = 1.0;
	[UIView commitAnimations];

}

- (UIImage*) getImage {
    UIImageView* iv = [[self subviews] objectAtIndex:0];
    return [iv image];
}


- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
	[media release];
    [super dealloc];
}









@end
