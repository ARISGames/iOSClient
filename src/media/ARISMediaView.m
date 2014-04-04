//
//  ARISMediaView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/1/13.
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
    UIImageView *playIcon;
    UIActivityIndicatorView *spinner;
    
    ARISDelegateHandle *selfDelegateHandle;
    id<ARISMediaViewDelegate> __unsafe_unretained delegate;
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
        self.frame = f; 
    } 
    return self;
}

- (id) initWithFrame:(CGRect)f media:(Media *)m mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        delegate = d; 
        displayMode = dm;
        self.frame = f;  
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
        self.frame = f;   
        [self setImage:i]; 
    }
    return self;
}

- (void) setFrame:(CGRect)f withMode:(ARISMediaDisplayMode)dm
{
    displayMode = dm;
    self.frame = f;
}

- (void) setMedia:(Media *)m
{
    image = nil;
    if(selfDelegateHandle) [selfDelegateHandle invalidate]; 
    if(!m.data)
    {
        [self addSpinner];
        
        selfDelegateHandle = [[ARISDelegateHandle alloc] initWithDelegate:self];
        
        [[AppServices sharedAppServices] loadMedia:m delegateHandle:selfDelegateHandle];
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

- (void) setFrame:(CGRect)f
{
    if(self.frame.origin.x == f.origin.x &&
       self.frame.origin.y == f.origin.y && 
       self.frame.size.width == f.size.width &&  
       self.frame.size.height == f.size.height)
        return; //dumb
    imageView = nil;
    if(spinner)   [self removeSpinner];
    if(playIcon)  [self removePlayIcon]; 
    for(int i = 0; i < [self.subviews count]; i++)
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    
    super.frame = f;
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    
    if     (media) [self displayMedia];
    else if(image) [self displayImage];
}

- (void) play
{
    if(!media || [media.type isEqualToString:@"IMAGE"] || !avVC) return;
    [self removePlayIcon];
    avVC.view.frame = self.bounds; 
    [self addSubview:avVC.view];  
    [avVC.moviePlayer play]; 
}

- (void) stop
{
    if(!media || [media.type isEqualToString:@"IMAGE"] || !avVC) return;
    [self addPlayIcon];
    [avVC.moviePlayer stop];
    [avVC.view removeFromSuperview];
}

- (void) mediaLoaded:(Media *)m
{
    [self removeSpinner]; 
    [self setMedia:m];
}

- (void) displayMedia //results in calling displayImage, displayVideo, or displayAudio
{
    NSString *type = media.type;
    if(avVC) {[avVC.view removeFromSuperview]; avVC = nil; [self removePlayIcon];}   
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
        [self displayAudio:media];
    } 
}

- (void) displayImage
{
    [imageView setImage:image];
    
    float mult = self.frame.size.width/image.size.width;
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
    
    switch(displayMode)
    {
        case ARISMediaDisplayModeTopAlignAspectFitWidth:
            imageView.frame = CGRectMake(0,0,self.frame.size.width,image.size.height*mult);
            break;
        case ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight:
            imageView.frame = CGRectMake(0,0,self.frame.size.width,image.size.height*mult);
            //instead of getting in infinite loop with "setFrame", just handle silent cleanup here 
            super.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,imageView.frame.size.height);
            if(playIcon) [self addPlayIcon]; //re-add play icon for sizing considerations
        default:
            break;
    }
    if(delegate && [(NSObject *)delegate respondsToSelector:@selector(ARISMediaViewUpdated:)])
        [delegate ARISMediaViewUpdated:self];
}

- (void) displayVideo:(Media *)m
{
    if(avVC) { [avVC.view removeFromSuperview]; avVC = nil; [self removePlayIcon];}
    
    [self addPlayIcon];
    
    avVC = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil]; 
    avVC.moviePlayer.shouldAutoplay = NO;
    [avVC.moviePlayer requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithFloat:1.0f]] timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayVideoThumbLoaded:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:avVC.moviePlayer];
    avVC.moviePlayer.controlStyle = MPMovieControlStyleNone;
}

- (void) displayVideoThumbLoaded:(NSNotification*)notification
{
    image = [UIImage imageWithData:UIImageJPEGRepresentation([notification.userInfo objectForKey:MPMoviePlayerThumbnailImageKey], 1.0)];
    [self displayImage];
    avVC.view.frame = imageView.frame;
}

- (void) displayAudio:(Media *)m
{
    if(avVC) { [avVC.view removeFromSuperview]; avVC = nil; [self removePlayIcon];}
    
    [self addPlayIcon];
    
    avVC = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];  
    avVC.moviePlayer.shouldAutoplay = NO;
    avVC.moviePlayer.controlStyle = MPMovieControlStyleNone;  
    image = [UIImage imageNamed:@"sound_with_bg.png"];
    [self displayImage];
}

- (void) playbackFinished:(NSNotification *)n
{
    [self stop]; 
    if([[n.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonUserExited)
        if(delegate && [(NSObject *)delegate respondsToSelector:@selector(ARISMediaViewFinishedPlayback:)])
            [delegate ARISMediaViewFinishedPlayback:self];
}

- (void) addSpinner
{
    if(spinner) [self removeSpinner];
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

- (void) addPlayIcon
{
    if(playIcon) [self removePlayIcon];
    playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play.png"]];
    [playIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playIconTouched)]];
    playIcon.userInteractionEnabled = YES;
    double h = self.frame.size.height;
    double w = self.frame.size.width; 
    if(h > 60) h = 60;
    if(w > 60) w = 60; 
    playIcon.frame = CGRectMake((self.frame.size.width-w)/2,(self.frame.size.height-h)/2,w,h);
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:playIcon];
}

- (void) removePlayIcon
{
    [playIcon removeFromSuperview];
    playIcon = nil;
}

- (void) playIconTouched
{
    if(delegate && [(NSObject *)delegate respondsToSelector:@selector(ARISMediaViewShouldPlayButtonTouched:)])
    {
        if([delegate ARISMediaViewShouldPlayButtonTouched:self])
            [self play];
    }
    else
        [self play];
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
    if(selfDelegateHandle) [selfDelegateHandle invalidate];
    if(avVC) [avVC.moviePlayer cancelAllThumbnailImageRequests]; 
}

@end
