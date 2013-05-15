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

#import "PLTexture.h"

@interface PLTexture()

- (BOOL)loadTextureWithObject:(id)object rotate:(int)angle;
- (void)deleteTexture;

@end

@implementation PLTexture

@synthesize textureId;
@synthesize width, height;
@synthesize isValid;

#pragma mark -
#pragma mark init methods

- (id)initWithImage:(UIImage *)image
{
	if(self = [super init])
		[self loadTextureWithImage:image];
	return self;
}

- (id)initWithPath:(NSString *)path
{
	if(self = [super init])
		[self loadTextureWithPath:path];
	return self;
}

- (id)initWithPathAndRelease:(NSString *)path
{
	[self initWithPath:path];
	[path release];
	return self;
}

- (id)initWithImage:(UIImage *)image rotate:(int) angle
{
	if(self = [super init])
		[self loadTextureWithImage:image rotate:angle];
	return self;
}

- (id)initWithPath:(NSString *)path rotate:(int)angle
{
	if(self = [super init])
		[self loadTextureWithPath:path rotate:angle];
	return self;
}

- (id)initWithPathAndRelease:(NSString *)path rotate:(int)angle
{
	[self initWithPath:path rotate:angle];
	[path release];
	return self;
}

+ (id)textureWithImage:(UIImage *)image
{
	return [[PLTexture alloc] initWithImage:image];
}

+ (id)textureWithPath:(NSString *)path
{
	return [[PLTexture alloc] initWithPath:path];
}

+ (id)textureWithPathAndRelease:(NSString *)path
{
	return [[PLTexture alloc] initWithPathAndRelease:path];
}

+ (id)textureWithImage:(UIImage *)image rotate:(int)angle
{
	return [[PLTexture alloc] initWithImage:image rotate:angle];
}

+ (id)textureWithPath:(NSString *)path rotate:(int)angle;
{
	return [[PLTexture alloc] initWithPath:path rotate:angle];
}

+ (id)textureWithPathAndRelease:(NSString *)path rotate:(int)angle
{
	return [[PLTexture alloc] initWithPathAndRelease:path rotate:angle];
}

#pragma mark -
#pragma mark load methods

- (BOOL)loadTextureWithObject:(id)object rotate:(int)angle
{
	[self deleteTexture];
	
	GLint saveName;
	
	glGenTextures(1, &textureId);
	
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	
	glBindTexture(GL_TEXTURE_2D, textureId);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	PLImage * plImage = [object isKindOfClass:[NSString class]] ? [PLImage imageWithPath:(NSString *)object] : [PLImage imageWithCGImage:[(UIImage *)object CGImage]];
	
	width = plImage.width;
	height = plImage.height;
	
	if(width > kTextureMaxWidth || height > kTextureMaxHeight)
		[NSException raise:@"Invalid texture size" format:@"Texture max size is %d x %d, currently is %d x %d", kTextureMaxWidth, kTextureMaxHeight, width, height];
	
	BOOL isResizableImage = NO;
	if(![PLMath isPowerOfTwo:width])
	{
		isResizableImage = YES;
		width = kTextureMaxWidth / 2;
	}
	if(![PLMath isPowerOfTwo:height])
	{
		isResizableImage = YES;
		height = kTextureMaxHeight / 2;
	}
	if(isResizableImage)
		[plImage scale:CGSizeMake(width, height)];
	
	if(angle != 0)
		[plImage rotate:angle];
	
	unsigned char * bits = plImage.bits;
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width , height, 0, GL_RGBA, GL_UNSIGNED_BYTE, bits);
	
	free(bits);
	
	glBindTexture(GL_TEXTURE_2D, saveName);
	
	GLenum errGL = glGetError();
	
	[plImage release];
	
	if(errGL != GL_NO_ERROR)
	{
		NSLog(@"loadTexture -> glGetError = (%d) %s ...", errGL, (const char *)gluErrorString(errGL));
		isValid = NO;
	}
	isValid = YES;
	return isValid;
}

- (BOOL)loadTextureWithPath:(NSString *)path
{
	return [self loadTextureWithPath:path rotate:0];
}

- (BOOL)loadTextureWithPath:(NSString *)path rotate:(int)angle
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NO])
		[NSException raise:@"File not exists" format:@"File %@ not exists", path];
	
	return [self loadTextureWithObject:path rotate:angle];
}

- (BOOL)loadTextureWithImage:(UIImage *)image
{
	return [self loadTextureWithImage:image rotate:0];
}

- (BOOL)loadTextureWithImage:(UIImage *)image rotate:(int)angle
{
	return [self loadTextureWithObject:image rotate:angle];
}

#pragma mark -
#pragma mark dealloc methods

- (void)deleteTexture
{
	if(textureId)
	{
		glDeleteTextures(1, &textureId);
		textureId = 0;
	}
}

- (void)dealloc
{
	[self deleteTexture];
	[super dealloc];
}

@end
