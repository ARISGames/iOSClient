//
//  ARISMediaView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/1/13.
//
//

#import "ARISMediaView.h"
#import "ARISMoviePlayerViewController.h"
#import "Media.h"
#import "AppServices.h"
#import "AppModel.h"
#import "UIImage+animatedGIF.h"

@interface ARISMediaView()
{
    ARISMediaDisplayMode displayMode;
    Media *media;
    
    UIImageView *imageView;
    ARISMoviePlayerViewController *movieViewController; //Only required to get thumbnail for video
    
    NSURLConnection* connection;
	NSMutableData* data;
    UIActivityIndicatorView *spinner;
        
    id <ARISMediaViewDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, assign) ARISMediaDisplayMode displayMode;
@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ARISMoviePlayerViewController *movieViewController;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation ARISMediaView

@synthesize displayMode;
@synthesize media;
@synthesize imageView;
@synthesize movieViewController;
@synthesize connection;
@synthesize data;
@synthesize spinner;

- (id) initWithFrame:(CGRect)frame media:(Media *)m mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:frame])
    {
        [self refreshWithFrame:frame media:m mode:dm delegate:d];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:frame])
    {
        [self refreshWithFrame:frame image:i mode:dm delegate:d];
    }
    return self;
}

- (void) refreshWithFrame:(CGRect)f
{
    [self initializeWithFrame:f inMode:self.displayMode delegate:delegate];
    if(self.image)      [self displayImage:self.image];
    else if(self.media) [self displayMedia:self.media];
}

- (void) refreshWithFrame:(CGRect)f media:(Media *)m mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    [self initializeWithFrame:(CGRect)f inMode:dm delegate:d];
    [self displayMedia:m];
}

- (void) refreshWithFrame:(CGRect)f image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    [self initializeWithFrame:(CGRect)f inMode:dm delegate:d];
    [self displayImage:i];
}

- (void) initializeWithFrame:(CGRect)f inMode:(ARISMediaDisplayMode)m delegate:(id<ARISMediaViewDelegate>)d
{
    self.imageView = nil;
    self.movieViewController = nil;
    if(self.connection) [self cancelConnection];
    if(self.spinner)    [self removeSpinner];
    for(int i = 0; i < [self.subviews count]; i++)
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    
    self.frame = f;
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    self.displayMode = m;
    switch(m)
    {
        case ARISMediaDisplayModeDefault:
        case ARISMediaDisplayModeAspectFill:
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            break;
        case ARISMediaDisplayModeStretchFill:
            imageView.contentMode = UIViewContentModeScaleToFill;
            break;
        case ARISMediaDisplayModeAspectFit:
        case ARISMediaDisplayModeTopAlignAspectFitWidth:
        case ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight:
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    }
    
    delegate = d;
}

- (void) displayMedia:(Media *)m //results in calling displayImage
{
    [self addSpinner];
    self.media = m;
    if(m.image)
    { 
        if([[self contentTypeForImageData:m.image] isEqualToString:@"image/gif"])
            [self displayImage:[UIImage animatedImageWithAnimatedGIFData:m.image]];  
        else
            [self displayImage:[UIImage imageWithData:m.image]];
        
        return;
    }
    
    if(!m.url || !m.type)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryLoadingMyMedia) name:@"ReceivedMediaList" object:nil];
        [[AppServices sharedAppServices] fetchMedia:[m.uid intValue]];
        return;
    }
    
    if([m.type isEqualToString:@"PHOTO"])      [self loadPhotoForMedia:m];
    else if([m.type isEqualToString:@"VIDEO"]) [self loadVideoFrameForMedia:m];
    else if([m.type isEqualToString:@"AUDIO"]) [self displayImage:[UIImage imageNamed:@"microphoneBackground.jpg"]];
}

- (void) loadPhotoForMedia:(Media *)m
{
    NSURL *url = [NSURL URLWithString:m.url];
    if([url isFileURL])
    {
        [self displayImage:[UIImage imageWithContentsOfFile:[url path]]];
        return;
    }

    //Phil hack until server is updated:
    m.url = [m.url stringByReplacingOccurrencesOfString:@"gamedata//" withString:@"gamedata/player/"];
    //End Phil hack
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:m.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    if(self.connection) [self.connection cancel];
    data = [[NSMutableData alloc] initWithCapacity:2048];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) loadVideoFrameForMedia:(Media *)m
{
    NSNumber *thumbTime = [NSNumber numberWithFloat:1.0f];
    NSArray *timeArray = [NSArray arrayWithObject:thumbTime];
    
    self.movieViewController = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:m.url]];
    self.movieViewController.moviePlayer.shouldAutoplay = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.movieViewController.moviePlayer];
    [self.movieViewController.moviePlayer requestThumbnailImagesAtTimes:timeArray timeOption:MPMovieTimeOptionNearestKeyFrame];
}

- (void) movieThumbDidFinish:(NSNotification*)n
{
    UIImage *i = [n.userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    self.media.image = UIImageJPEGRepresentation(i, 1.0);
    [self displayImage:i];
}

- (void) connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    [self.data appendData:incrementalData];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)theConnection
{
    if(theConnection != self.connection) return;
    
    UIImage *i;
    if([[self contentTypeForImageData:self.data] isEqualToString:@"image/gif"])
        i = [UIImage animatedImageWithAnimatedGIFData:self.data]; 
    else
        i = [UIImage imageWithData:self.data];
    if(i) self.media.image = self.data;
    [self cancelConnection];
	[self displayImage:i];
}

- (void) displayImage:(UIImage *)i
{
    [self.imageView setImage:i];
    if(self.spinner) [self removeSpinner];
    
    float mult = self.frame.size.width/i.size.width;
    switch(self.displayMode)
    {
        case ARISMediaDisplayModeTopAlignAspectFitWidth:
            self.imageView.frame = CGRectMake(0,0,self.frame.size.width,i.size.height*mult);
            break;
        case ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight:
            self.imageView.frame = CGRectMake(0,0,self.frame.size.width,i.size.height*mult);
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.imageView.frame.size.height);
        default:
            break;
    }
    if(delegate && [(NSObject *)delegate respondsToSelector:@selector(ARISMediaViewUpdated:)])
        [delegate ARISMediaViewUpdated:self];
}

- (UIImage *) image
{
    return self.imageView.image;
}

- (void)retryLoadingMyMedia
{
    NSLog(@"Failed to load media %d previously- new media list received so trying again...", [self.media.uid intValue]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeSpinner];//will be added upon displaymedia attempt
    [self displayMedia:[[AppModel sharedAppModel] mediaForMediaId:[self.media.uid intValue] ofType:@"PHOTO"]]; //guess that it's a photo
}

- (void) addSpinner
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.center;
    [self addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void) removeSpinner
{
	[self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}

- (void) cancelConnection
{
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}
       
- (NSString *) contentTypeForImageData:(NSData *)d
{
    uint8_t c;
    [d getBytes:&c length:1];
   
    switch(c)
    {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (void) dealloc
{
    if(self.connection) [self cancelConnection];
    if(self.movieViewController) [self.movieViewController.moviePlayer cancelAllThumbnailImageRequests];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
