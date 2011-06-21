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

#import <OpenGLES/EAGL.h>
#import "glu.h"

#import "PLImage.h"
#import "PLMath.h"

@interface PLTexture : NSObject 
{
	GLuint textureId;
	int width, height;
	BOOL isValid;
}

@property (nonatomic, readonly) GLuint textureId;
@property (nonatomic, readonly) int width, height;
@property (nonatomic, readonly) BOOL isValid;

- (id)initWithImage:(UIImage *)image;
- (id)initWithPath:(NSString *)path;
- (id)initWithPathAndRelease:(NSString *)path;
- (id)initWithImage:(UIImage *)image rotate:(int)angle;
- (id)initWithPath:(NSString *)path rotate:(int)angle;
- (id)initWithPathAndRelease:(NSString *)path rotate:(int)angle;

+ (id)textureWithImage:(UIImage *)image;
+ (id)textureWithPath:(NSString *)path;
+ (id)textureWithPathAndRelease:(NSString *)path;
+ (id)textureWithImage:(UIImage *)image rotate:(int)angle;
+ (id)textureWithPath:(NSString *)path rotate:(int)angle;
+ (id)textureWithPathAndRelease:(NSString *)path rotate:(int)angle;

- (BOOL)loadTextureWithImage:(UIImage *)image;
- (BOOL)loadTextureWithImage:(UIImage *)image rotate:(int)angle;
- (BOOL)loadTextureWithPath:(NSString *)path;
- (BOOL)loadTextureWithPath:(NSString *)path rotate:(int)angle;

@end
