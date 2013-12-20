//
//  ARISMediaView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/1/13.
//
//

#import "ARISMediaView.h"
#import "Media.h"
#import "AppServices.h"
#import "UIImage+animatedGIF.h"
#import "ARISMediaLoader.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ARISMediaView() <ARISMediaLoaderDelegate>
{
    ARISMediaDisplayMode displayMode;
    Media *media;
    UIImage *image; 
    
    UIImageView *imageView;
    MPMoviePlayerViewController *avVC;
    UIActivityIndicatorView *spinner;
        
    id <ARISMediaViewDelegate> delegate;
}

@end

@implementation ARISMediaView

- (id) initWithDelegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:CGRectMake(0,0,64,64)])
    {
        delegate = d;
    }
    return self;
}

- (id) initWithFrame:(CGRect)f
{
    if(self = [super initWithFrame:f])
    {
        [self refreshFrameWithFrame:f]; 
    } 
    return self;
}

- (id) initWithFrame:(CGRect)f media:(Media *)m mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        delegate = d; 
        displayMode = dm;
        [self refreshFrameWithFrame:f];  
        [self setMedia:m];
    }
    return self;
}

- (id) initWithFrame:(CGRect)f image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        delegate = d;
        displayMode = dm;
        [self refreshFrameWithFrame:f];   
        [self setImage:i]; 
    }
    return self;
}

- (void) setFrame:(CGRect)f withMode:(ARISMediaDisplayMode)dm
{
    displayMode = dm;
    [self refreshFrameWithFrame:f];
}

- (void) setMedia:(Media *)m
{
    image = nil;
    if(!m.data)
    {
        [self addSpinner];
        [[AppServices sharedAppServices] loadMedia:m delegate:self];
        return;//this function will be called upon media's return
    } 
    media = m;
    [self displayMedia]; 
}

- (void) setImage:(UIImage *)i
{
    media = nil;
    image = i;
    [self displayImage]; 
}

- (void) setDelegate:(id<ARISMediaViewDelegate>)d
{
    delegate = d;
}

- (void) refreshFrameWithFrame:(CGRect)f
{
    imageView = nil;
    if(spinner) [self removeSpinner];
    for(int i = 0; i < [self.subviews count]; i++)
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    
    self.frame = f;
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    switch(displayMode)
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
    
    if     (media) [self displayMedia];
    else if(image) [self displayImage];  
}

- (void) mediaLoaded:(Media *)m
{
    [self removeSpinner]; 
    [self setMedia:m];
}

- (void) displayMedia //results in calling displayImage
{
    NSString *type = media.type;
    if([type isEqualToString:@"IMAGE"])
    {
        NSString *dataType = [self contentTypeForImageData:media.data];
        if     ([dataType isEqualToString:@"image/gif"])
        {
            image = [UIImage animatedImageWithAnimatedGIFData:media.data];
            [self displayImage];  
        }
        else if([dataType isEqualToString:@"image/jpeg"] ||
                [dataType isEqualToString:@"image/png"]) 
        {
            image = [UIImage imageWithData:media.data];
            [self displayImage]; 
        }
    }
    else if([type isEqualToString:@"VIDEO"])
    {
        [self displayVideo:media];
    }
    else if([type isEqualToString:@"AUDIO"])
    {
        
    } 
}

- (void) displayImage
{
    [imageView setImage:image];
    
    float mult = self.frame.size.width/image.size.width;
    switch(displayMode)
    {
        case ARISMediaDisplayModeTopAlignAspectFitWidth:
            imageView.frame = CGRectMake(0,0,self.frame.size.width,image.size.height*mult);
            break;
        case ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight:
            imageView.frame = CGRectMake(0,0,self.frame.size.width,image.size.height*mult);
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,imageView.frame.size.height);
        default:
            break;
    }
    if(delegate && [(NSObject *)delegate respondsToSelector:@selector(ARISMediaViewUpdated:)])
        [delegate ARISMediaViewUpdated:self];
}

- (void) displayVideo:(Media *)m
{
    if(avVC) { [avVC.view removeFromSuperview]; avVC = nil; }
    
    avVC = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
    avVC.moviePlayer.shouldAutoplay = NO;
    [avVC.moviePlayer requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithFloat:1.0f]] timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayVideoThumbLoaded:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:avVC.moviePlayer]; 
}

- (void) displayVideoThumbLoaded:(NSNotification*)notification
{
    image = [UIImage imageWithData:UIImageJPEGRepresentation([notification.userInfo objectForKey:MPMoviePlayerThumbnailImageKey], 1.0)];
    [self displayImage];
    avVC.view.frame = imageView.frame;
    [self addSubview:avVC.view]; 
    
    [avVC.moviePlayer play];
}

- (void) displayAudio:(Media *)m
{
    if(avVC) { [avVC.view removeFromSuperview]; avVC = nil; } 
       avVC = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
    avVC.moviePlayer.shouldAutoplay = NO;
    image = [UIImage imageNamed:@"audio.png"];
    [self displayImage];
    [avVC.moviePlayer play]; 
}

- (void) addSpinner
{
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.center;
    [self addSubview:spinner];
    [spinner startAnimating];
}

- (void) removeSpinner
{
	[spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];  
    if(avVC) [avVC.moviePlayer cancelAllThumbnailImageRequests]; 
}

@end
