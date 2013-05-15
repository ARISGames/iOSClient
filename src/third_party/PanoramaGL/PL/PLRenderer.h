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
#import <QuartzCore/CAEAGLLayer.h>
#import "glu.h"

#import "PLStructs.h"
#import "PLCamera.h"
#import "PLScene.h"
#import "PLSceneElement.h"
#import "PLViewBase.h"

@interface PLRenderer : NSObject 
{
    EAGLContext *context;
	
	GLint backingWidth, backingHeight;
    
    GLuint viewRenderbuffer, viewFramebuffer, depthRenderbuffer;
	BOOL isUsedDepthBuffer;
	
	PLViewBase * view;
	PLScene * scene;
	
	UIDeviceOrientation currentOrientation;
	
	float aspect;
}

@property (nonatomic, readonly) GLint backingWidth, backingHeight;
@property (nonatomic) BOOL isUsedDepthBuffer;
@property (nonatomic, retain) PLViewBase * view;
@property (nonatomic, retain) PLScene * scene;
@property (nonatomic, readonly) UIDeviceOrientation currentOrientation;

- (id)initWithView:(PLViewBase *)view scene:(PLScene *)scene;

+ (id)rendererWithView:(PLViewBase *)view scene:(PLScene *)scene;

- (void)render;
- (void)renderNTimes:(NSUInteger)times;
- (void)renderWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
- (void)renderNTimesWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation times:(NSUInteger)times;

@end
