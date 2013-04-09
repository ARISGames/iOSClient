//
//  AsyncImageView.m
//  ARIS
//
//  Created by David J Gagnon on 11/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "AsyncMediaImageView.h"
#import "AppModel.h"
#import "AppServices.h"
#import "UIImage+Scale.h"
@implementation AsyncMediaImageView

@synthesize connection;
@synthesize data;
@synthesize media;
@synthesize mMoviePlayer;
@synthesize isLoading;
@synthesize loaded;
@synthesize delegate;

-(id)initWithFrame:(CGRect)aFrame andMedia:(Media *)aMedia
{
    self.media = aMedia;
    return [self initWithFrame:aFrame andMediaId:[aMedia.uid intValue]];
}

-(id)initWithFrame:(CGRect)aFrame andMediaId:(int)mediaId
{
    if (self = [super initWithFrame:aFrame])
    {
        self.loaded = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
        
        if(!media)
            media = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
        
        if([media.type isEqualToString:kMediaTypeImage])
            [self loadImageFromMedia:media];
        else if([media.type isEqualToString:kMediaTypeVideo] || [media.type isEqualToString:kMediaTypeAudio])
        {
            if(self.media.image)
            {
                [self updateViewWithNewImage:[UIImage imageWithData:self.media.image]];
                self.loaded = YES;
            }
            else if([media.type isEqualToString:kMediaTypeVideo])
            {
                NSNumber *thumbTime = [NSNumber numberWithFloat:1.0f];
                NSArray *timeArray = [NSArray arrayWithObject:thumbTime];
                
                //Create movie player object
                if(!self.mMoviePlayer)
                {
                    ARISMoviePlayerViewController *mMoviePlayerAlloc = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString: media.url]];
                    self.mMoviePlayer = mMoviePlayerAlloc;
                }
                else
                {
                    ARISMoviePlayerViewController *mMoviePlayerAlloc = [self.mMoviePlayer initWithContentURL:[NSURL URLWithString: media.url]];
                    self.mMoviePlayer = mMoviePlayerAlloc; 
                }
            
                self.mMoviePlayer.moviePlayer.shouldAutoplay = NO;
                [self.mMoviePlayer.moviePlayer requestThumbnailImagesAtTimes:timeArray timeOption:MPMovieTimeOptionNearestKeyFrame];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.mMoviePlayer.moviePlayer];
                
                //set up indicators
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                //put a spinner in the view
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [spinner startAnimating];
                
                spinner.center = self.center;
                [self addSubview:spinner];
                
                self.isLoading= YES;
            }
            else if ([media.type isEqualToString:kMediaTypeAudio])
            {
                self.media.image = UIImageJPEGRepresentation([UIImage imageNamed:@"microphoneBackground.jpg"], 1.0);
                [self updateViewWithNewImage:[UIImage imageNamed:@"microphoneBackground.jpg"]];
                self.loaded = YES;
            }
        }
    }
    return self;
}

-(void)movieThumbDidFinish:(NSNotification*)aNotification
{
    NSLog(@"AsyncMediaImageView: movieThumbDidFinish");
    NSDictionary *userInfo = aNotification.userInfo;
    UIImage *videoThumb = [userInfo objectForKey:MPMoviePlayerThumbnailImageKey];

    UIImage *videoThumbSized = [videoThumb scaleToSize:self.frame.size];        
    self.media.image = UIImageJPEGRepresentation(videoThumbSized,1.0 ) ;     
    [self updateViewWithNewImage:[UIImage imageWithData:self.media.image]];

    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFinishedLoading:)])
        [delegate imageFinishedLoading:self];
    
    //end the UI indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    //clear out the spinner
    while([[self subviews] count] > 0)
		[[[self subviews] lastObject] removeFromSuperview];
    
    self.loaded    = YES;
    self.isLoading = NO;
}

- (void)loadImageFromMedia:(Media *) aMedia
{
    if(self.isLoading) return;

    self.media = aMedia;
    
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    self.isLoading = YES;

	//check if the media already as the image, if so, just grab it
	if (self.media.image)
    {
        [self updateViewWithNewImage:[UIImage imageWithData:self.media.image]];
        self.loaded = YES;
        self.isLoading = NO;
		return;
	}

    if (!self.media.url)
    {
        NSLog(@"AsyncImageView: loadImageFromMedia with null url! Trying to load from server (mediaId:%d)",[self.media.uid intValue]);
        self.isLoading = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryLoadingMyMedia) name:@"ReceivedMediaList" object:nil];
        [[AppServices sharedAppServices] fetchMedia:[self.media.uid intValue]];
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
	
	NSLog(@"AsyncImageView: Loading Image at %@",self.media.url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: self.media.url]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
    if(connection) [connection cancel];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)retryLoadingMyMedia
{
    NSLog(@"Failed to load media %d previously- new media list received so trying again...", [self.media.uid intValue]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self loadImageFromMedia:[[AppModel sharedAppModel] mediaForMediaId:[self.media.uid intValue]]];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    if (self.data==nil)
		data = [[NSMutableData alloc] initWithCapacity:2048];
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection
{
	//end the UI indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    //clear out the spinner
    while ([[self subviews] count] > 0)
		[[[self subviews] lastObject] removeFromSuperview];
    
	//throw out the connection
    if(self.connection!=nil) self.connection=nil;
	
	//turn the data into an image
	UIImage* image = [UIImage imageWithData:data];
	
	//Save the image in the media
    if(image) self.media.image = data;
    
    //throw out the data

    self.loaded = YES;
	self.isLoading = NO;
	[self updateViewWithNewImage:[UIImage imageWithData:self.media.image]];
    self.data = nil;
    
    NSLog(@"NSNotification: ImageReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ImageReady" object:nil]];
}

- (void) updateViewWithNewImage:(UIImage*)image
{
    self.alpha = 1.0;
    if(image)
    {
        [self setImage:image];
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageFinishedLoading:)])
            [delegate imageFinishedLoading:self];
    }
    self.isLoading = NO;
    self.loaded = YES;
}

- (void) setImage:(UIImage*)image
{
    super.image = image;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
	[self.superview setNeedsLayout];
}

- (void)dealloc
{
    if(connection) [connection cancel];
    if(mMoviePlayer) [mMoviePlayer.moviePlayer cancelAllThumbnailImageRequests];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
