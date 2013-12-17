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
    UIImage *image; 
    
    UIImageView *imageView;
    UIActivityIndicatorView *spinner;
        
    id <ARISMediaViewDelegate> delegate;
}

@end

@implementation ARISMediaView

- (id) initWithDelegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:CGRectMake(0,0,64,64)])
    {
        displayMode = ARISMediaDisplayModeAspectFit;
        delegate = d;
    }
    return self;
}

- (id) initWithFrame:(CGRect)f media:(Media *)m mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        [self initializeWithFrame:f inMode:dm delegate:delegate]; 
        [self displayMedia:m];
    }
    return self;
}

- (id) initWithFrame:(CGRect)f image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        [self initializeWithFrame:f inMode:dm delegate:delegate]; 
        [self displayImage:i]; 
    }
    return self;
}

- (void) setFrame:(CGRect)f withMode:(ARISMediaDisplayMode)dm
{
    [self initializeWithFrame:f inMode:dm delegate:delegate];
    if     (media) [self displayMedia:media];
    else if(image) [self displayImage:image]; 
}

- (void) setMedia:(Media *)m
{
    [self displayMedia:m]; 
}

- (void) setImage:(UIImage *)i
{
    [self displayImage:i]; 
}

- (void) setDelegate:(id<ARISMediaViewDelegate>)d
{
    delegate = d;
}

- (void) initializeWithFrame:(CGRect)f inMode:(ARISMediaDisplayMode)m delegate:(id<ARISMediaViewDelegate>)d
{
    imageView = nil;
    if(spinner) [self removeSpinner];
    for(int i = 0; i < [self.subviews count]; i++)
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    
    self.frame = f;
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    displayMode = m;
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
    media = m;
    [self displayMedia:m];
}

- (void) displayMedia:(Media *)m //results in calling displayImage
{
    media = m;
    
    if(!media.data)
    {
        [self addSpinner];
        [[AppServices sharedAppServices] loadMedia:media delegate:self];
        return;//this function will be called upon media's return
    }
    
    if(m.data)
    { 
        NSString *dataType = [self contentTypeForImageData:m.data];
        if     ([dataType isEqualToString:@"image/gif"])
            [self displayImage:[UIImage animatedImageWithAnimatedGIFData:m.data]];  
        else if([dataType isEqualToString:@"image/jpeg"] ||
                [dataType isEqualToString:@"image/png"]) 
            [self displayImage:[UIImage imageWithData:m.data]];
    }
}

- (void) displayImage:(UIImage *)i
{
    image = i;
    [imageView setImage:i];
    
    float mult = self.frame.size.width/i.size.width;
    switch(displayMode)
    {
        case ARISMediaDisplayModeTopAlignAspectFitWidth:
            imageView.frame = CGRectMake(0,0,self.frame.size.width,i.size.height*mult);
            break;
        case ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight:
            imageView.frame = CGRectMake(0,0,self.frame.size.width,i.size.height*mult);
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,imageView.frame.size.height);
        default:
            break;
    }
    if(delegate && [(NSObject *)delegate respondsToSelector:@selector(ARISMediaViewUpdated:)])
        [delegate ARISMediaViewUpdated:self];
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
}

@end
