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

#import <UIKit/UIImage.h>
#import <Foundation/NSData.h>

@interface PLImage : NSObject 
{
	CGImageRef cgImage;
	int width, height;
}

@property(nonatomic, readonly, getter=getWidth) int width;
@property(nonatomic, readonly, getter=getHeight) int height;

@property(nonatomic, readonly, getter=getCGImage) CGImageRef CGImage;

@property(nonatomic, readonly, getter=getCount) int count;
@property(nonatomic, readonly, getter=getBits) unsigned char * bits;

- (id)initWithCGImage:(CGImageRef)image;
- (id)initWithSize:(CGSize)size;
- (id)initWithDimensions:(int)width :(int)height;
- (id)initWithPath:(NSString *)path;

+ (id)imageWithSizeZero;
+ (id)imageWithCGImage:(CGImageRef)image;
+ (id)imageWithSize:(CGSize)size;
+ (id)imageWithDimensions:(int) width :(int)height;
+ (id)imageWithPath:(NSString *)path;

- (int)getWidth;
- (int)getHeight;
- (CGSize)getSize;
- (CGRect)getRect;

- (CGImageRef)getCGImage;

- (int)getCount;
- (unsigned char *)getBits;

- (BOOL)isValid;
- (BOOL)equals:(PLImage *)image;
- (PLImage *)assign:(PLImage *)image;

- (PLImage *)clone;
- (CGImageRef)cloneCGImage;

- (PLImage *)crop:(CGRect)rect;

- (PLImage *)scale:(CGSize)size;

- (PLImage *)rotate:(int)angle;

- (PLImage *)mirrorHorizontally;
- (PLImage *)mirrorVertically;
- (PLImage *)mirror:(BOOL)horizontally :(BOOL)vertically;

- (BOOL)save:(NSString *)path;
- (BOOL)save:(NSString *)path quality:(int)quality;

@end
