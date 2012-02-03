//
//  AsyncImageView.m
//  ARIS
//
//  Created by David J Gagnon on 11/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "AsyncImageView.h"
#import "AppModel.h"
#import "UIImage+Scale.h"
@implementation AsyncImageView

@synthesize connection;
@synthesize data;
@synthesize media;
@synthesize delegate,isLoading,loaded,mMoviePlayer,mediaPlayBackButton,aframe;


-(void)initWithMediaId:(int)mediaId andFrame:(CGRect)aFrame andDelegate:(id)delegateToPresentMoviePlayer{
    self.aframe = aFrame;
    self.delegate = delegateToPresentMoviePlayer;
    if(!media){
    media = [[Media alloc] init];
    }
    media = [[AppModel sharedAppModel] mediaForMediaId:mediaId];

    if([media.type isEqualToString:@"Image"]){
        [self loadImageFromMedia:media];
    }
    else if([media.type isEqualToString:@"Video"] || [media.type isEqualToString:@"Audio"]){
       self.userInteractionEnabled = YES;
        if(!mediaPlayBackButton){
        mediaPlayBackButton = [[UIButton alloc] init];
        }
        
            [mediaPlayBackButton setFrame:aframe];
        
        if(!mMoviePlayer){
            mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        }
        else{
            [mMoviePlayer initWithContentURL:[NSURL URLWithString:media.url]];

        }
                //Create movie player object
        mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [mMoviePlayer.moviePlayer prepareToPlay];
        //Setup the overlay
               if([media.type isEqualToString:@"Video"]){
        if (!media.image) {
            /* UIImage *videoThumb = [mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact];            
             UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(320, 240)];        
             [mediaPlaybackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];*/
            NSNumber *thumbTime = [NSNumber numberWithFloat:1.0f];
            NSArray *timeArray = [NSArray arrayWithObject:thumbTime];
            [mMoviePlayer.moviePlayer requestThumbnailImagesAtTimes:timeArray timeOption:MPMovieTimeOptionNearestKeyFrame];
            
            NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
            [dispatcher addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:mMoviePlayer.moviePlayer];
            
        }
        else {
            [mediaPlayBackButton setBackgroundImage:media.image forState:UIControlStateNormal];
            //mediaPlayBackButton.contentMode = UIViewContentModeScaleAspectFill;
        }
        }
        else{
            if(!media.image){
                media.image = [UIImage imageNamed:@"microphoneBackground.jpg"];
                
            }
            [mediaPlayBackButton setBackgroundImage:media.image forState:UIControlStateNormal];
            mediaPlayBackButton.contentMode = UIViewContentModeScaleAspectFill;  
        }
        
            [mediaPlayBackButton setFrame:aframe];
        [mediaPlayBackButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        [mediaPlayBackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [mediaPlayBackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        
        [mediaPlayBackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];

             [self addSubview:mediaPlayBackButton];

        [mediaPlayBackButton release];
    }
   
}
-(void)movieThumbDidFinish:(NSNotification*) aNotification
{
    NSDictionary *userInfo = aNotification.userInfo;
    UIImage *videoThumb = [userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    NSError *e = [userInfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    NSNumber *time = [userInfo objectForKey:MPMoviePlayerThumbnailTimeKey];
    MPMoviePlayerController *player = aNotification.object;
    UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(aframe.size.width,aframe.size.height)];        
    
     [mediaPlayBackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
    media.image = videoThumbSized;        
            
    if (e) {
        //NSLog(@"MPMoviePlayerThumbnail ERROR: %@",e);
    }
}
-(void)playMovie:(id)sender {
    if([self.delegate respondsToSelector:@selector(presentMoviePlayerViewControllerAnimated:)]){
    [self.delegate presentMoviePlayerViewControllerAnimated:mMoviePlayer];
    }
}

- (void)loadImageFromMedia:(Media *) aMedia {
	self.media = aMedia;
    self.image = nil;
    
	if(self.isLoading){
        NSLog(@"AsyncImageView: loadImageFromMedia: Already loading another request...returning");
      //  [self.connection release];
       // [self.data release];
        //clear out the spinner
    }
    self.isLoading = YES;

	//check if the media already as the image, if so, just grab it
	if (self.media.image) {
		[self updateViewWithNewImage:self.media.image];
        self.loaded = YES;
		return;
	}

    if (!self.media.url) {
        NSLog(@"AsyncImageView: loadImageFromMedia with null url! ImageId:%@", self.media.uid);
        return;
    }
	
    self.loaded = NO;

	//set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//put a spinner in the view
	UIActivityIndicatorView *spinner = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[spinner startAnimating];
	
	spinner.center = self.center;
	[self addSubview:spinner];
	
	if (connection!=nil) { [connection release]; }
    //if (data!=nil) { [self.data release]; }
	NSLog(@"AsyncImageView: Loading Image at %@",self.media.url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc]initWithString:self.media.url]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (self.data==nil) {
		self.data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//end the UI indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    //clear out the spinner
    while ([[self subviews] count] > 0) {
		[[[self subviews] lastObject] removeFromSuperview];
    }
    
	//throw out the connection
    [self.connection release];
    self.connection=nil;
	
	//turn the data into an image
	UIImage* image = [UIImage imageWithData:data];
	
	//throw out the data
	[self.data release];
    self.data=nil;
	
	//Save the image in the media
	self.media.image = image;
    self.loaded = YES;
	self.isLoading= NO;
	[self updateViewWithNewImage:image];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ImageReady" object:nil]];

}

- (void) updateViewWithNewImage:(UIImage*)image {
	/*[UIView beginAnimations:@"async" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.1];
	self.alpha = 0;
	[UIView commitAnimations];

	self.image = image;
	[UIView beginAnimations:@"async" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25];
	self.alpha = 1.0;
	[UIView commitAnimations];*/
    self.alpha = 1.0;
    [self setImage:image];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFinishedLoading)]){
        [delegate imageFinishedLoading];
    }

}

- (void) setImage:(UIImage*)image {
    super.image = image;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
	[self.superview setNeedsLayout];
}

- (void)dealloc {
    [super dealloc];

    [connection cancel];
    [connection release];
    [data release];
	//[media release];
    //[delegate release];
    [mMoviePlayer release];
    //[mediaPlayBackButton release];
}









@end
