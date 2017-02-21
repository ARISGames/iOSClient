/*===============================================================================
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#if !TARGET_OS_SIMULATOR

#import "Texture.h"
#import <UIKit/UIKit.h>

#define TEX_SIZE 256

// Private method declarations
@interface Texture (PrivateMethods)
- (BOOL)loadImage:(NSString*)filename;
- (BOOL)copyImageDataForOpenGL:(CFDataRef)imageData;
@end


@implementation Texture

//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id)initWithImageFile:(NSString*)filename
{
    self = [super init];
    
    if (nil != self) {
        if (NO == [self loadImage:filename]) {
            NSLog(@"Failed to load texture image from file %@", filename);
            self = nil;
        }
    }
    
    return self;
}


- (void)dealloc
{
    if (_pngData) {
        delete[] _pngData;
    }
}

- (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height
{
  // create context, keeping original image properties
  CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
  CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                               CGImageGetBitsPerComponent(image),
                                               CGImageGetBitsPerPixel(image)/8*width,//CGImageGetBytesPerRow(image),
                                               colorspace,
                                               CGImageGetAlphaInfo(image));
  CGColorSpaceRelease(colorspace);
  
  if(context == NULL) return nil;
  
  // draw image to context (resizing it)
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
  // extract resulting image from context
  CGImageRef imgRef = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  
  return imgRef;
}

- (BOOL) loadAbsoImageNoResize:(NSString *)filename
{
  // Build the full path of the image file
  NSString* fullPath = filename;//[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
  
  // Create a UIImage with the contents of the file
  UIImage* uiImage = [UIImage imageWithContentsOfFile:fullPath];
  
  BOOL ret = NO;
  
  if(uiImage)
  {
    // Get the inner CGImage from the UIImage wrapper
    CGImageRef cgImage = uiImage.CGImage;
    
    // Get the image size
    _width = (int)CGImageGetWidth(cgImage);
    _height = (int)CGImageGetHeight(cgImage);
    
    // Record the number of channels
    _channels = (int)CGImageGetBitsPerPixel(cgImage)/CGImageGetBitsPerComponent(cgImage);
    
    // Generate a CFData object from the CGImage object (a CFData object represents an area of memory)
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    
    // Copy the image data for use by Open GL
    ret = [self copyImageDataForOpenGL:imageData];
    
    CFRelease(imageData);
  }
  
  return ret;
}

- (BOOL) loadUIImage:(UIImage *)image
{
  BOOL ret = NO;
  
  if(image)
  {
    // Get the inner CGImage from the UIImage wrapper
    CGImageRef cgImage = [self resizeCGImage:image.CGImage toWidth:TEX_SIZE andHeight:TEX_SIZE];
    
    // Get the image size
    _width = (int)CGImageGetWidth(cgImage);
    _height = (int)CGImageGetHeight(cgImage);
    
    // Record the number of channels
    _channels = (int)CGImageGetBitsPerPixel(cgImage)/CGImageGetBitsPerComponent(cgImage);
    
    // Generate a CFData object from the CGImage object (a CFData object represents an area of memory)
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    
    // Copy the image data for use by Open GL
    ret = [self copyImageDataForOpenGL:imageData];
    
    CFRelease(imageData);
  }
  
  return ret;
}

- (BOOL) loadAbsoImage:(NSString*)filename
{
    // Build the full path of the image file
    NSString* fullPath = filename;//[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    
    // Create a UIImage with the contents of the file
    UIImage* uiImage = [UIImage imageWithContentsOfFile:fullPath];
    return [self loadUIImage:uiImage];
}

- (BOOL) loadImage:(NSString*)filename
{
  // Build the full path of the image file
  NSString* fullPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
  return [self loadAbsoImage:fullPath];
}

//------------------------------------------------------------------------------
#pragma mark - Private methods


- (BOOL)copyImageDataForOpenGL:(CFDataRef)imageData
{
    if (_pngData) {
        delete[] _pngData;
    }
    
    _pngData = new unsigned char[_width * _height * _channels];
    const int rowSize = _width * _channels;
    const unsigned char* pixels = (unsigned char*)CFDataGetBytePtr(imageData);
    
    // Copy the row data from bottom to top
    for (int i = 0; i < _height; ++i) {
        memcpy(_pngData + rowSize * i, pixels + rowSize * (_height - 1 - i), _width * _channels);
    }
    
    return YES;
}

@end

#endif
