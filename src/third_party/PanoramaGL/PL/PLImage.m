/*
 * This file is part of the PanoramaGL library.
 *
 *  Author: Javier Baez <javbaezga@gmail.com>
 *
 *  $Id$
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; version 3 of
 * the License
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

#import "PLImage.h"

@interface PLImage ()

- (void)createWithPath:(NSString *)path;
- (void)createWithSize:(CGSize)size;
- (void)createWithCGImage:(CGImageRef)image;

- (PLImage *)mirroredByOrientation:(UIImageOrientation)orient;

- (void)deleteImage;

@end

@implementation PLImage

#pragma mark -
#pragma mark init methods

- (id)init
{
	if(self = [super init])
		[self createWithSize:CGSizeMake(0,0)];
	return self;
}

- (id)initWithCGImage:(CGImageRef)image
{
	if(self = [super init])
		[self createWithCGImage:image];
	return self;
}

- (id)initWithSize:(CGSize) size
{
	if(self = [super init])
		[self createWithSize:size];
	return self;
}

- (id)initWithDimensions:(int)w :(int)h
{
	return [self initWithSize:CGSizeMake(w, h)];
}

- (id)initWithPath:(NSString *)path
{
	if(self = [super init])
		[self createWithPath:path];
	return self;
}

+ (id)imageWithCGImage:(CGImageRef)image
{
	return [[PLImage alloc] initWithCGImage:image];
}

+ (id)imageWithSize:(CGSize)size
{
	return [[PLImage alloc] initWithSize:size];
}

+ (id)imageWithDimensions:(int)width :(int)height
{
	return [[PLImage alloc] initWithDimensions:width :height];
}

+ (id)imageWithPath:(NSString *)path
{
	return [[PLImage alloc] initWithPath:path];
}

+ (id)imageWithSizeZero
{
	return [[PLImage alloc] init];
}

- (void)createWithPath:(NSString *)path
{
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
	cgImage = CGImageRetain(image.CGImage);
	width = CGImageGetWidth(cgImage);
	height = CGImageGetHeight(cgImage);
	[image release];
}

- (void)createWithCGImage:(CGImageRef)image
{
	width = CGImageGetWidth(image);
	height = CGImageGetHeight(image);
	cgImage = CGImageCreateWithImageInRect(image, CGRectMake(0, 0, width, height));
}

- (void)createWithSize:(CGSize)size
{
	UIGraphicsBeginImageContext(CGRectMake(0, 0, size.width, size.height).size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef image = CGBitmapContextCreateImage(context);
	[self deleteImage];
	[self createWithCGImage:image];
	CGImageRelease(image);
	UIGraphicsEndImageContext();
}

#pragma mark -
#pragma mark property methods

- (int)getWidth
{
	return width;
}

- (int)getHeight
{
	return height;
}

- (CGSize)getSize
{
	return CGSizeMake(width, height);
}

- (CGRect)getRect
{
	return CGRectMake(0, 0, width, height);
}

- (int)getCount
{
	return [self getWidth] * [self getHeight] * 4;
}

- (CGImageRef)getCGImage
{
	return cgImage;
}

- (unsigned char *)getBits
{	
	int w = [self getWidth], h = [self getHeight];
	CGImageRef image = [self getCGImage];
	unsigned char * data = (unsigned char *) malloc(w * h * 4);
	CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w * 4,
												 CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
	
	CGContextScaleCTM(context, -1.0, -1.0);
	CGContextTranslateCTM(context, -w, -h);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, (CGFloat) w, (CGFloat) h), image);
	CGContextRelease(context);
	return data;	
}

#pragma mark -
#pragma mark operation methods

- (BOOL)isValid
{
	return ([self getCGImage] == nil);
}

- (BOOL)equals:(PLImage *)image
{	
	if ([image getCGImage] == [self getCGImage])
		return YES;
	if (![image getCGImage] || ![self getCGImage] || [image getHeight] != [self getHeight] || [image getWidth] != [self getWidth])
		return NO;
	unsigned char * bits = [image getBits];
	unsigned char * _bits = [self getBits];
	for(int i = 0; i < [self getCount] ; i++, bits++, _bits++)
	{
		if(*bits != *_bits)
			return NO;
	}
	return YES;
}

- (PLImage *)assign:(PLImage *)image
{
	[self deleteImage];
	[self createWithCGImage:image.CGImage];
	return self;
}

#pragma mark -
#pragma mark clone methods

- (CGImageRef)cloneCGImage
{	
	return CGImageCreateWithImageInRect([self getCGImage], CGRectMake(0, 0, [self getWidth], [self getHeight]));
}

- (PLImage *)clone
{
	return [PLImage imageWithCGImage:[self getCGImage]];
}

#pragma mark -
#pragma mark crop methods

- (PLImage *)crop:(CGRect)rect
{
	CGImageRef image = CGImageCreateWithImageInRect([self getCGImage], rect);
	
	[self deleteImage];
	[self createWithCGImage:image];
	
	CGImageRelease(image);
	
	return self;
}

#pragma mark -
#pragma mark scale methods

- (PLImage *)scale:(CGSize)size
{
	if (![self getCGImage]) 
	{
		NSLog(@"PLImage::scaled: CGImage is nil");
		return self;
	}
	if ((size.width == 0 && size.height == 0) || (size.width == [self getWidth] && size.height == [self getHeight]))
		return self;
	
	int w = size.width;
	int h = size.height;
	
	UIGraphicsBeginImageContext(CGRectMake(0, 0, w, h).size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	if (context == NULL)
	{
		NSLog(@"PLImage::scaled, CGContext was not created!");
		return self;
	}
		
	CGContextTranslateCTM(context, 0.0, h);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), [self getCGImage]);
	CGImageRef image = CGBitmapContextCreateImage(context);

	[self deleteImage];
	[self createWithCGImage:image];
	
	CGImageRelease(image);
	UIGraphicsEndImageContext();
	
	return self;
}

#pragma mark -
#pragma mark rotate methods

- (PLImage *)rotate:(int)angle
{
	if(angle % 90 != 0)
		return self;
	
	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat w = CGImageGetWidth([self getCGImage]);
	CGFloat h = CGImageGetHeight([self getCGImage]);
	
	CGRect rect = CGRectMake(0, 0, w, h);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(rect, transform);
		
	CGColorSpaceRef colorSpace = CGImageGetColorSpace([self getCGImage]);
	
	CGContextRef context = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGImageAlphaPremultipliedLast);
	
	CGContextSetAllowsAntialiasing(context, FALSE);
	CGContextSetInterpolationQuality(context, kCGInterpolationNone);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(context,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(context, angleInRadians);
	CGContextTranslateCTM(context,
						  -(rotatedRect.size.width/2),
						  -(rotatedRect.size.height/2));
	CGContextDrawImage(context, CGRectMake(0, 0,
											 rotatedRect.size.width,
											 rotatedRect.size.height),
					   [self getCGImage]);
	
	CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
	
	[self deleteImage];
	[self createWithCGImage:rotatedImage];
	
	CGImageRelease(rotatedImage);
	CGContextRelease(context);
	
	return self;
}

#pragma mark -
#pragma mark mirror methods

- (PLImage *)mirrorHorizontally
{
	return [self mirroredByOrientation:UIImageOrientationUpMirrored];
}

- (PLImage *)mirrorVertically
{
	return [self mirroredByOrientation:UIImageOrientationDownMirrored];
}

- (PLImage *)mirroredByOrientation:(UIImageOrientation)orient
{
	CGRect             bounds = CGRectZero;
	CGContextRef       context = nil;
	CGImageRef         image = [self getCGImage];
	CGRect             rect = CGRectZero;
	CGAffineTransform  transform = CGAffineTransformIdentity;
		
	rect.size.width  = CGImageGetWidth(image);
	rect.size.height = CGImageGetHeight(image);
	
	bounds = rect;
	
	switch (orient)
	{				
		case UIImageOrientationUpMirrored:
			transform = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
		default:
			assert(false);
			return self;
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	context = UIGraphicsGetCurrentContext();
	
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0.0, -rect.size.height);
	
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, image);
	image = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
	
	[self deleteImage];
	[self createWithCGImage:image];
	
	CGImageRelease(image);
	UIGraphicsEndImageContext();
	
	return self;
}

- (PLImage *)mirror:(BOOL)horizontally :(BOOL)vertically
{
	int w = [self getWidth], h = [self getHeight];
	CGImageRef image = [self getCGImage];
	unsigned char * data = (unsigned char *) malloc(w * h * 4);
	CGContextRef context = CGBitmapContextCreate(data, w, h, 8, w * 4,
														CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
	
	CGContextScaleCTM(context, !horizontally ? -1.0 : 1.0 , !vertically ? -1.0 : 0);
	CGContextTranslateCTM(context, !horizontally ? -w : 0 , !vertically ? -h : 0);
	
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, (CGFloat) w, (CGFloat) h), image);
	CGImageRef cgimage = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());	
	free(data);
	
	[self deleteImage];
	[self createWithCGImage:cgimage];
	
	CGImageRelease(cgimage);
	CGContextRelease(context);
	
	return self;
}

#pragma mark -
#pragma mark save methods

- (BOOL)save:(NSString *)path
{
	return [self save:path quality:80];
}

- (BOOL)save:(NSString *)path quality:(int)quality
{
	if([self isValid])
		return NO;
	quality = (quality <= 0 ? 80 : MIN(quality, 100));
	NSData *data = UIImageJPEGRepresentation([UIImage imageWithCGImage:[self getCGImage]], (CGFloat) quality/100.0f);
	return ([data writeToFile:path atomically:YES] == YES);
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc
{
	[self deleteImage];
	[super dealloc];
}

-(void) deleteImage
{
	if(cgImage)
		CGImageRelease(cgImage);
}

@end
