//
//  ARISMediaView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/1/13.
//
//

#import "ARISMediaView.h"
#import "Media.h"
#import "AppModel.h"
#import "AppServices.h"
#import "UIImage+animatedGIF.h"
#import "ARISMediaLoader.h"

@interface ARISMediaView() <ARISMediaLoaderDelegate>
{
    ARISMediaDisplayMode displayMode;
    Media *media;
    
    UIImageView *imageView;
    UIActivityIndicatorView *spinner;
        
    id <ARISMediaViewDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, assign) ARISMediaDisplayMode displayMode;
@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation ARISMediaView

@synthesize displayMode;
@synthesize media;
@synthesize imageView;
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
    if(self.spinner) [self removeSpinner];
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

- (void) mediaLoaded:(Media *)m
{
    [self removeSpinner]; 
    self.media = m;
    [self displayMedia:m];
}

- (void) displayMedia:(Media *)m //results in calling displayImage
{
    self.media = m;
    
    if(!self.media.image)
    {
        [self addSpinner];
        [[AppServices sharedAppServices] loadMedia:self.media delegate:self];
        return;//this function will be called upon media's return
    }
    
    if(m.image)
    { 
        if([[self contentTypeForImageData:m.image] isEqualToString:@"image/gif"])
            [self displayImage:[UIImage animatedImageWithAnimatedGIFData:m.image]];  
        else
            [self displayImage:[UIImage imageWithData:m.image]];
    }
    else if([m.type isEqualToString:@"AUDIO"]) [self displayImage:[UIImage imageNamed:@"microphoneBackground.jpg"]];
}

- (void) displayImage:(UIImage *)i
{
    [self.imageView setImage:i];
    
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
}

@end
