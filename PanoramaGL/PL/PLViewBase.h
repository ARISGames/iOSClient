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

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>

#import "PLEnums.h"
#import "PLMath.h"
#import "PLScene.h"
#import "PLCamera.h"
#import "PLViewDelegate.h"
#import "PLControlDelegate.h"
#import "PLControl.h"
#import "PLControlZoomIn.h"
#import "PLControlZoomOut.h"

@class PLRenderer;

@interface PLViewBase : UIView <UIAccelerometerDelegate, PLControlDelegate> 
{
	PLRenderer * renderer;
	PLScene * scene;
	
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
	
	CGPoint startPoint, endPoint;
	
	BOOL isValidForFov;
	float fovDistance;
	
	BOOL isDeviceOrientationEnabled, isValidForOrientation;
	UIDeviceOrientation deviceOrientation;
	PLOrientationSupported deviceOrientationSupported;
	
	BOOL isAccelerometerEnabled, isAccelerometerLeftRightEnabled, isAccelerometerUpDownEnabled;
	float accelerometerSensitivity;
	NSTimeInterval accelerometerInterval;
	
	BOOL isScrollingEnabled, isValidForScrolling, isScrolling;
	NSUInteger minDistanceToEnableScrolling;
	
	BOOL isInertiaEnabled, isValidForInertia;
	NSTimer *inertiaTimer;
	NSTimeInterval inertiaInterval;
	float inertiaStepValue;
	
	BOOL isResetEnabled, isShakeResetEnabled;
	
	PLShakeData shakeData;
	
	BOOL isValidForTouch;
	
	NSMutableArray *controlsArray;
	PLControlTypeSupported controlTypeSupported;
	
	NSObject<PLViewDelegate> *delegate;
}

@property(nonatomic, readonly, getter=getCamera) PLCamera * camera;

@property(nonatomic) NSTimeInterval animationInterval;

@property(nonatomic) BOOL isDeviceOrientationEnabled;
@property(nonatomic) UIDeviceOrientation deviceOrientation;
@property(nonatomic) PLOrientationSupported deviceOrientationSupported;

@property(nonatomic) BOOL isAccelerometerEnabled, isAccelerometerLeftRightEnabled, isAccelerometerUpDownEnabled;
@property(nonatomic) float accelerometerSensitivity;
@property(nonatomic) NSTimeInterval accelerometerInterval;

@property(nonatomic) CGPoint startPoint, endPoint;

@property(nonatomic) BOOL isScrollingEnabled;
@property(nonatomic) NSUInteger minDistanceToEnableScrolling;

@property(nonatomic) BOOL isInertiaEnabled;
@property(nonatomic) NSTimeInterval inertiaInterval;

@property(nonatomic) BOOL isResetEnabled, isShakeResetEnabled;

@property(nonatomic) PLControlTypeSupported controlTypeSupported;

@property(nonatomic, assign) NSObject<PLViewDelegate> *delegate;

- (PLCamera *)getCamera;

- (void)reset;

- (void)drawView;
- (void)drawViewNTimes:(NSUInteger)times;

- (void)startAnimation;
- (void)stopAnimation;

- (UIDeviceOrientation)currentDeviceOrientation;

+ (Class)layerClass;

@end