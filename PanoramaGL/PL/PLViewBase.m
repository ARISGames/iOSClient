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

#import "PLViewBase.h"

@interface PLViewBase ()

@property (nonatomic, assign) NSTimer *animationTimer;

- (void)allocAndInitVariables;
- (void)initializeValues;

- (BOOL)calculateFov:(NSSet *)touches;

- (BOOL)executeDefaultAction:(NSSet *)touches;
- (BOOL)executeResetAction:(NSSet *)touches;

- (void)activateAccelerometer;
- (void)deactiveAccelerometer;

- (void)stopAnimationInternally;

- (void)startInertia;
- (void)stopInertia;
- (void)inertia;

- (void)activateOrientation;
- (void)deactiveOrientation;
- (void)changeOrientation:(UIDeviceOrientation)orientation;
- (void)orientationChanged:(UIDeviceOrientation)orientation;
- (BOOL)isOrientationValid:(UIDeviceOrientation)orientation;

- (BOOL)isTouchInView:(NSSet *)touches;
- (CGPoint)getLocationOfFirstTouch:(NSSet *)touches;

- (void)drawViewInternally;
- (void)drawViewInternallyNTimes:(NSUInteger)times;



- (BOOL)resetWithShake:(UIAcceleration *)acceleration;

- (void)createControls;
- (void)removeControls;
- (void)loadControls;
- (void)changeControlsOrientation;

-(void) enableGyro;
-(void)getDeviceGLRotationMatrix;

@end

@implementation PLViewBase

@synthesize animationTimer,gyroTimer;
@synthesize animationInterval;

@synthesize isDeviceOrientationEnabled;
@synthesize deviceOrientation;
@synthesize deviceOrientationSupported;

@synthesize isAccelerometerEnabled, isAccelerometerLeftRightEnabled, isAccelerometerUpDownEnabled,isGyroEnabled,gyroInit;
@synthesize accelerometerSensitivity,initYaw,initRoll,initPitch;
@synthesize accelerometerInterval;

@synthesize startPoint, endPoint;

@synthesize isScrollingEnabled;
@synthesize minDistanceToEnableScrolling;

@synthesize isInertiaEnabled;
@synthesize inertiaInterval;

@synthesize isResetEnabled, isShakeResetEnabled;

@synthesize controlTypeSupported;

@synthesize referenceAttitude;

@synthesize delegate;

#pragma mark -
#pragma mark init methods 

- (id)initWithCoder:(NSCoder*)coder 
{
    
    if ((self = [super initWithCoder:coder])) 
	{
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		[self allocAndInitVariables];
		[self initializeValues];
    }
    return self;
}

- (void)allocAndInitVariables
{
	scene = [PLScene scene];
	renderer = [PLRenderer rendererWithView:self scene:[scene retain]];
}

- (void)initializeValues
{
	animationInterval = kDefaultAnimationTimerInterval;
    
    referenceAttitude = nil;
    
	isAccelerometerEnabled = NO;
	isAccelerometerLeftRightEnabled = YES;
	isAccelerometerUpDownEnabled = NO;
    isGyroEnabled = NO;
	accelerometerSensitivity = kDefaultAccelerometerSensitivity;
	accelerometerInterval = kDefaultAccelerometerInterval;
	
	isDeviceOrientationEnabled = NO;
	deviceOrientationSupported = PLOrientationSupportedAll;
	
	isScrollingEnabled = NO;
	minDistanceToEnableScrolling = 100000;//kDefaultMinDistanceToEnableScrolling;
	
	isInertiaEnabled = YES;
	inertiaInterval = kDefaultInertiaInterval;
	
	isValidForTouch = NO;
	
	isResetEnabled = isShakeResetEnabled = YES;
	
	shakeData = PLShakeDataMake(0);
	
	controlTypeSupported = PLControlTypeSupportedAll;
	controlsArray = [[NSMutableArray array] retain];
	//[self createControls];
	//[self loadControls];
    
    
	
	[self reset];
}

- (void)reset
{
	[self stopAnimation];
	isValidForFov = isValidForScrolling = isScrolling = isValidForInertia = isValidForOrientation = NO;
	startPoint = endPoint = CGPointMake(0.0f, 0.0f);
	fovDistance = 0.0f;
	if(isDeviceOrientationEnabled)
		self.deviceOrientation = [self currentDeviceOrientation];
}

#pragma mark -
#pragma mark property method

- (PLCamera *)getCamera
{
	if(scene)
		return scene.currentCamera;
	return nil;
}

#pragma mark -
#pragma mark layer method 

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark draw methods 

-(UIImage *) getSnapshot {
    NSInteger myDataLength = 320 * 480 * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, 320, 480, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < 480; y++)
    {
        for(int x = 0; x < 320 * 4; x++)
        {
            buffer2[(479 - y) * 320 * 4 + x] = buffer[y * 4 * 320 + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * 320;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(320, 480, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}


- (void)drawView
{
	if(isScrolling && delegate && [delegate respondsToSelector:@selector(view:shouldScroll:endPoint:)] && ![delegate view:self shouldScroll:startPoint endPoint:endPoint])
		return;
	[self drawViewInternally];
	if(isScrolling && delegate && [delegate respondsToSelector:@selector(view:didScroll:endPoint:)])
		[delegate view:self didScroll:startPoint endPoint:endPoint];
}

- (void)drawViewNTimes:(NSUInteger)times
{
	for(int i = 0; i < times; i++)
		[self drawView];
}

- (void)drawViewInternally
{
}

- (void)drawViewInternallyNTimes:(NSUInteger)times
{
	for(int i = 0; i < times; i++)
		[self drawViewInternally];
}

- (void)layoutSubviews 
{
	[super layoutSubviews];
	[self activateOrientation];
	[self activateAccelerometer];
	[self drawViewInternallyNTimes:2];
}

#pragma mark -
#pragma mark animation methods 

- (void)startAnimation 
{
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
	if(isScrollingEnabled)
		isValidForScrolling = YES;
	[self stopInertia];
}

- (void)stopAnimation
{
	[self stopAnimationInternally];
	[self stopInertia];
}

- (void)stopAnimationInternally 
{
	if(animationTimer)
		[animationTimer invalidate];
    self.animationTimer = nil;
	
	if(isScrollingEnabled)
	{
		isValidForScrolling = NO;
		if(!isInertiaEnabled)
			isValidForTouch = NO;
	}
	else
		isValidForTouch = NO;
}

- (void)setAnimationTimer:(NSTimer *)newTimer 
{
    [animationTimer invalidate];
    animationTimer = newTimer;
}

- (void)setAnimationInterval:(NSTimeInterval)interval 
{    
    animationInterval = interval;
	if (animationTimer) 
	{
        [self stopAnimationInternally];
        [self startAnimation];
    }
}

#pragma mark -
#pragma mark action methods

- (BOOL)calculateFov:(NSSet *)touches
{
	if(![self executeResetAction:touches] && [touches count] == 2)
	{
		startPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
		endPoint = [[[touches allObjects] objectAtIndex:1] locationInView:self];
		
		float distance = [PLMath distanceBetweenPoints:startPoint :endPoint];
		
		if(ABS(distance - fovDistance) < scene.currentCamera.minDistanceToEnableFov)
			return NO;
		
		distance = ABS(fovDistance) <= distance ? distance : -distance;
		BOOL isZoomIn = (distance >= 0);
		BOOL isCancelable = NO;
		
		if(delegate && [delegate respondsToSelector:@selector(view:shouldRunZooming:isZoomIn:isZoomOut:)])
			isCancelable = [delegate view:self shouldRunZooming:distance isZoomIn:isZoomIn isZoomOut:!isZoomIn];
		
		if(!isCancelable)
		{
			fovDistance = distance;
			if(delegate && [delegate respondsToSelector:@selector(view:didRunZooming:isZoomIn:isZoomOut:)])
				[delegate view:self didRunZooming:fovDistance isZoomIn:isZoomIn isZoomOut:!isZoomIn];
			return YES;
		}
	}
	return NO;
}

- (BOOL)executeDefaultAction:(NSSet *)touches
{
    return NO;
	if(isValidForFov)
		[self calculateFov:touches];
	else
	{
		int touchCount = [touches count];
		if(![self executeResetAction:touches] && touchCount == 2)
		{
			BOOL isCancelable = NO;
			if(delegate && [delegate respondsToSelector:@selector(viewShouldBeginZooming:)])
				isCancelable = [delegate viewShouldBeginZooming:self];
			if(!isCancelable)
			{
				isValidForFov = YES;
				startPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
				endPoint = [[[touches allObjects] objectAtIndex:1] locationInView:self];
				[self startAnimation];
				if(delegate && [delegate respondsToSelector:@selector(view:didBeginZooming:endPoint:)])
					[delegate view:self didBeginZooming:startPoint endPoint:endPoint];
			}
		}
		else if(touchCount == 1)
			return NO;
	}
	return YES;
}

- (BOOL)executeResetAction:(NSSet *)touches
{
	if(isResetEnabled && [touches count] >= 3) 
	{
		BOOL isCancelable = NO;
		if(delegate && [delegate respondsToSelector:@selector(viewShouldReset:)])
			isCancelable = [delegate viewShouldReset:self];
		if(!isCancelable)
		{
			[self reset];
			[self drawViewInternally];
			isValidForFov = YES;
			if(delegate && [delegate respondsToSelector:@selector(viewDidReset:)])
				[delegate viewDidReset:self];
			return YES;
		}
	}
	return NO;
}

#pragma mark -
#pragma mark touch methods

- (BOOL)isMultipleTouchEnabled
{
	return YES;
}

- (BOOL)isTouchInView:(NSSet *)touches
{
	for(UITouch *touch in touches)
		if(touch.view != self)
			return NO;
	return YES;
}

- (CGPoint)getLocationOfFirstTouch:(NSSet *)touches
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	return [touch locationInView:touch.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if(isValidForFov)
		return;
	
	NSSet *eventTouches = [event allTouches];

	if(![self isTouchInView:eventTouches])
		return;
	
	if(delegate && [delegate respondsToSelector:@selector(view:shouldBeginTouching:withEvent:)] && ![delegate view:self shouldBeginTouching:eventTouches withEvent:event])
		return;
	
	[self stopInertia];

	if([[eventTouches anyObject] tapCount] == 2)
	{
		if(isValidForScrolling)
		{
			[self stopAnimationInternally];
			isScrolling = NO;
			
			if(delegate && [delegate respondsToSelector:@selector(view:didEndScrolling:endPoint:)])
				[delegate view:self didEndScrolling:startPoint endPoint:endPoint];
			
			return;
		}
	}
	
	isValidForTouch = YES;
	
	if(![self executeDefaultAction:eventTouches])
	{
		startPoint = endPoint = [self getLocationOfFirstTouch:eventTouches];
		[self startAnimation];
	}
	
	if(delegate && [delegate respondsToSelector:@selector(view:didBeginTouching:withEvent:)])
		[delegate view:self didBeginTouching:eventTouches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *eventTouches = [event allTouches];
	
	if(![self isTouchInView:eventTouches])
		return;
	
	if(delegate && [delegate respondsToSelector:@selector(view:shouldTouch:withEvent:)] && ![delegate view:self shouldTouch:eventTouches withEvent:event])
		return;
	
	if(![self executeDefaultAction:eventTouches])
		endPoint = [self getLocationOfFirstTouch:eventTouches];
	
	if(delegate && [delegate respondsToSelector:@selector(view:didTouch:withEvent:)])
		[delegate view:self didTouch:eventTouches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopAnimationInternally];
    isScrolling = NO;
    
    if(delegate && [delegate respondsToSelector:@selector(view:didEndScrolling:endPoint:)])
        [delegate view:self didEndScrolling:startPoint endPoint:endPoint];
    
    return;

	NSSet *eventTouches = [event allTouches];
	
	if(![self isTouchInView:eventTouches])
		return;
	
	if(delegate && [delegate respondsToSelector:@selector(view:shouldEndTouching:withEvent:)] && ![delegate view:self shouldEndTouching:eventTouches withEvent:event])
		return;
		
	if(isValidForFov)
	{
		if([eventTouches count] == [touches count])
		{
			[self stopAnimation];
			isValidForFov = isValidForTouch = NO;
		}
	}
	else 
	{
		if(![self executeDefaultAction:eventTouches])
		{
			endPoint = [self getLocationOfFirstTouch:eventTouches];
			BOOL isCancelable = NO;
				
			if(isScrollingEnabled && delegate && [delegate respondsToSelector:@selector(view:shouldBeingScrolling:endPoint:)])
				isCancelable = [delegate view:self shouldBeingScrolling:startPoint endPoint:endPoint];
				
			if(isScrollingEnabled && !isCancelable)
			{
				BOOL isValidForMove = ((startPoint.x == endPoint.x && startPoint.y == endPoint.y) || [PLMath distanceBetweenPoints:startPoint :endPoint] <= minDistanceToEnableScrolling);
				if(isInertiaEnabled)
				{
					[self stopAnimationInternally];
					if(isValidForMove)
						isValidForTouch = NO;
					else
					{
						isCancelable = NO;
						if(delegate && [delegate respondsToSelector:@selector(view:shouldBeginInertia:endPoint:)])
							isCancelable = [delegate view:self shouldBeginInertia:startPoint endPoint:endPoint];
						if(!isCancelable)
							[self startInertia];
					}
				}
				else
				{
					if(isValidForMove)
						[self stopAnimationInternally];
					else
					{
						isScrolling = YES;
						if(delegate && [delegate respondsToSelector:@selector(view:didBeginScrolling:endPoint:)])
							[delegate view:self didBeginScrolling:startPoint endPoint:endPoint];
					}
				}
			}
			else
			{
				startPoint = endPoint;
				[self stopAnimationInternally];
				if(delegate && [delegate respondsToSelector:@selector(view:didEndMoving:endPoint:)])
					[delegate view:self didEndMoving:startPoint endPoint:endPoint];
			}
		}
	}
	
	if(delegate && [delegate respondsToSelector:@selector(view:didEndTouching:withEvent:)])
		[delegate view:self didEndTouching:eventTouches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(isValidForFov)
	{
		if([[event allTouches] count] == [touches count])
		{
			[self stopAnimation];
			isValidForFov = isValidForTouch = NO;
		}
	}
}

#pragma mark -
#pragma mark inertia methods

- (void)startInertia
{
	[self stopInertia];
	float interval = inertiaInterval / [PLMath distanceBetweenPoints:startPoint :endPoint];
	if(interval < 0.01f)
	{
		inertiaStepValue = 0.01f / interval;
		interval = 0.01f;
	}
	else
		inertiaStepValue = 1.0f;
	inertiaTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(inertia) userInfo:nil repeats:YES];
	
	if(delegate && [delegate respondsToSelector:@selector(view:didBeginInertia:endPoint:)])
		[delegate view:self didBeginInertia:startPoint endPoint:endPoint];
}

- (void)stopInertia
{
	if(inertiaTimer)
		[inertiaTimer invalidate];
	inertiaTimer = nil;
}

- (void)inertia
{
	if(delegate && [delegate respondsToSelector:@selector(view:shouldRunInertia:endPoint:)] && ![delegate view:self shouldRunInertia:startPoint endPoint:endPoint])
		return;
	
	float m = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
	float b = (startPoint.y * endPoint.x - endPoint.y * startPoint.x) / (endPoint.x - startPoint.x);
	float x, y, add;
	
	if(ABS(endPoint.x - startPoint.x) >= ABS(endPoint.y - startPoint.y))
	{
		add = (endPoint.x > startPoint.x ? -inertiaStepValue : inertiaStepValue);
		x = endPoint.x + add;
		if((add > 0.0f && x > startPoint.x) || (add <= 0.0f && x < startPoint.x))
		{
			[self stopInertia];
			isValidForTouch = NO;
			
			if(delegate && [delegate respondsToSelector:@selector(view:didEndInertia:endPoint:)])
				[delegate view:self didEndInertia:startPoint endPoint:endPoint];
			
			return;
		}
		y = m * x + b;
	}
	else
	{
		add = (endPoint.y > startPoint.y ? -inertiaStepValue : inertiaStepValue);
		y = endPoint.y + add;
		if((add > 0.0f && y > startPoint.y) || (add <= 0.0f && y < startPoint.y))
		{
			[self stopInertia];
			isValidForTouch = NO;
			
			if(delegate && [delegate respondsToSelector:@selector(view:didEndInertia:endPoint:)])
				[delegate view:self didEndInertia:startPoint endPoint:endPoint];
			
			return;
		}
		x = (y - b)/m;
	}
	endPoint = CGPointMake(x, y);
	[self drawView];
	
	if(delegate && [delegate respondsToSelector:@selector(view:didRunInertia:endPoint:)])
		[delegate view:self didRunInertia:startPoint endPoint:endPoint];
}

#pragma mark -
#pragma mark accelerometer methods

- (void)setAccelerometerInterval:(NSTimeInterval)value
{
	accelerometerInterval = value;
	[self activateAccelerometer];
}

- (void)setAccelerometerSensitivity:(float)value
{
	accelerometerSensitivity = [PLMath valueInRange:value range:PLRangeMake(kAccelerometerSensitivityMinValue, kAccelerometerSensitivityMaxValue)];
}

- (void)activateAccelerometer
{
	UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
	if(accelerometer)
	{
		accelerometer.updateInterval = accelerometerInterval;
		accelerometer.delegate = self;
	}
	else
		NSLog(@"Accelerometer not running on the device!");
}

- (void)deactiveAccelerometer
{
	UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
	if(accelerometer)
		accelerometer.delegate = nil;
}
 
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if([self resetWithShake:acceleration])
		return;
	
	if(isValidForTouch || isValidForOrientation)
		return;
	
	if(isAccelerometerEnabled)
	{
		if(delegate && [delegate respondsToSelector:@selector(view:shouldAccelerate:withAccelerometer:)] && ![delegate view:self shouldAccelerate:acceleration withAccelerometer:accelerometer])
			return;
		
		UIAccelerationValue x = 0, y = 0;
		float factor = kAccelerometerMultiplyFactor * accelerometerSensitivity;
		if(isDeviceOrientationEnabled)
		{
			switch (deviceOrientation) 
			{
				case UIDeviceOrientationUnknown:
				case UIDeviceOrientationPortrait:
				case UIDeviceOrientationPortraitUpsideDown:
					x = (isAccelerometerLeftRightEnabled ? acceleration.x : 0.0f);
					y = (isAccelerometerUpDownEnabled ? acceleration.z : 0.0f);
					startPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
					break;
				case UIDeviceOrientationLandscapeLeft:
				case UIDeviceOrientationLandscapeRight:
					x = (isAccelerometerUpDownEnabled ? -acceleration.z : 0.0f);
					y = (isAccelerometerLeftRightEnabled ? -acceleration.y : 0.0f);
					startPoint = CGPointMake(self.bounds.size.height / 2.0f, self.bounds.size.width / 2.0f);
					break;
				default:
					startPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
					break;
			}
		}
		else 
		{
			UIDeviceOrientation currentOrientation = [self currentDeviceOrientation];
			switch (currentOrientation) 
			{
				case UIDeviceOrientationUnknown:
				case UIDeviceOrientationPortrait:
				case UIDeviceOrientationPortraitUpsideDown:
					x = (isAccelerometerLeftRightEnabled ? acceleration.x : 0.0f);
					y = (isAccelerometerUpDownEnabled ? acceleration.z : 0.0f);
					startPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
					if(currentOrientation == UIDeviceOrientationPortraitUpsideDown)
					{
						x = -x;
						y = -y;
					}
					break;
				case UIDeviceOrientationLandscapeLeft:
				case UIDeviceOrientationLandscapeRight:
					x = (isAccelerometerLeftRightEnabled ? -acceleration.y : 0.0f);
					y = (isAccelerometerUpDownEnabled ? -acceleration.z : 0.0f);
					startPoint = CGPointMake(self.bounds.size.height / 2.0f, self.bounds.size.width / 2.0f);
					if(currentOrientation == UIDeviceOrientationLandscapeRight)
					{
						x = -x;
						y = -y;
					}
					break;
				default:
					startPoint = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
					break;
			}
		}

		endPoint = CGPointMake(startPoint.x + (x * factor), startPoint.y + (y * factor));
		[self drawView];
		
		if(delegate && [delegate respondsToSelector:@selector(view:didAccelerate:withAccelerometer:)])
			[delegate view:self didAccelerate:acceleration withAccelerometer:accelerometer];
	}
}
#pragma mark -
#pragma mark gyro methods

-(void) enableGyro{
    CMDeviceMotion *deviceMotion = [AppModel sharedAppModel].motionManager.deviceMotion;      
    //CMAttitude *attitude = deviceMotion.attitude;
    //referenceAttitude = [attitude retain];
    self.gyroTimer = [NSTimer scheduledTimerWithTimeInterval:.03 target:self selector:@selector(getDeviceGLRotationMatrix) userInfo:nil repeats:YES];
}


-(void) getDeviceGLRotationMatrix 
{
    //NSLog(@"PLViewBase: getDeviceGLRotationMatrix");
    if (!self.isGyroEnabled )return;
    
   // NSLog(@"PLViewBase: getDeviceGLRotationMatrix: Camera Started at roll: %f pitch: %f yaw: %f",scene.currentCamera.roll,scene.currentCamera.pitch,scene.currentCamera.yaw);
    
    CMAttitude *attitude = [AppModel sharedAppModel].motionManager.deviceMotion.attitude;
    if (!gyroInit && attitude) {
        gyroInit = YES;
        initPitch = attitude.pitch*180/M_PI;
        initRoll = attitude.roll*180/M_PI;
        initYaw = attitude.yaw*180/M_PI;
        referenceAttitude = [attitude retain];
    }
    
   // NSLog(@"PLViewBase: getDeviceGLRotationMatrix: roll: %f pitch: %f yaw: %f\n",attitude.roll* 180/M_PI,attitude.pitch* 180/M_PI,attitude.yaw* 180/M_PI);
    
    scene.currentCamera.isRollEnabled = YES;
    scene.currentCamera.isPitchEnabled= YES;
    scene.currentCamera.isYawEnabled = YES;
   // if (referenceAttitude != nil) [attitude multiplyByInverseOfAttitude:referenceAttitude];
    int sign = 1;
    if(ABS(attitude.roll* 180/M_PI)>90) sign = -1;
    else sign =  1;
    
    float newPitch, newYaw, newRoll;
    newYaw = ((attitude.yaw - referenceAttitude.yaw) * 180/M_PI);
    newRoll = ((attitude.roll - referenceAttitude.roll)*180/M_PI);
    newPitch = (sign*ABS(attitude.pitch - M_PI/2)* 180/M_PI);
    NSLog(@"Pitch: %f  Yaw: %f Roll: %f",newPitch,newYaw,newRoll);
       [scene.currentCamera rotateWithPitch:newPitch  yaw:newYaw roll:newRoll];
    
  // NSLog(@"PLViewBase: getDeviceGLRotationMatrix: Camera is now at pitch: %f yaw: %f roll: %f\n",(scene.currentCamera.pitch) ,(scene.currentCamera.yaw),scene.currentCamera.roll);

    [self drawView];
}

#pragma mark -
#pragma mark orientation methods

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
{
	if(deviceOrientation != orientation && [self isOrientationValid:orientation])
	{
		deviceOrientation = orientation;
		[self changeOrientation: orientation];
	}
}

- (void)activateOrientation
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRotate:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)deactiveOrientation
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)didRotate:(NSNotification *)notification
{
	if(isDeviceOrientationEnabled && [self isOrientationValid:[self currentDeviceOrientation]])
	{
		if(delegate && [delegate respondsToSelector:@selector(view:shouldRotate:)] && ![delegate view:self shouldRotate:[self currentDeviceOrientation]])
			return;
		
		deviceOrientation = [self currentDeviceOrientation];
		[self changeOrientation: deviceOrientation];
		
		if(delegate && [delegate respondsToSelector:@selector(view:didRotate:)])
			[delegate view:self didRotate:deviceOrientation];
	}
	[self changeControlsOrientation];
}

- (void)changeOrientation:(UIDeviceOrientation)orientation
{
	isValidForOrientation = YES;
	[self orientationChanged: orientation];
	[self drawView];
	isValidForOrientation = NO;
}

- (void)orientationChanged:(UIDeviceOrientation)orientation
{
}

- (BOOL)isOrientationValid:(UIDeviceOrientation)orientation
{
	PLOrientationSupported value;
	switch (orientation) 
	{
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationPortrait:
			value = PLOrientationSupportedPortrait;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			value = PLOrientationSupportedPortraitUpsideDown;
			break;
		case UIDeviceOrientationLandscapeLeft:
			value = PLOrientationSupportedLandscapeLeft;
			break;
		case UIDeviceOrientationLandscapeRight:
			value = PLOrientationSupportedLandscapeRight;
			break;
		default:
			return NO;
	}
	return (deviceOrientationSupported & value);
}

- (UIDeviceOrientation)currentDeviceOrientation
{
	return [[UIDevice currentDevice] orientation];
}

#pragma mark -
#pragma mark shake methods

- (BOOL)resetWithShake:(UIAcceleration *)acceleration
{
	if(!isAccelerometerEnabled || !isShakeResetEnabled || !isResetEnabled || isValidForOrientation)
		return NO;
	
	BOOL result = NO;
	long currentTime = (long)(CACurrentMediaTime() * 1000);
	
	if ((currentTime - shakeData.lastTime) > kShakeDiffTime)
	{
		long diffTime = (currentTime - shakeData.lastTime);
		shakeData.lastTime = currentTime;
		
		shakeData.shakePosition.x = acceleration.x;
		shakeData.shakePosition.y = acceleration.y;
		shakeData.shakePosition.z = acceleration.z;
		
		float speed = ABS(shakeData.shakePosition.x + shakeData.shakePosition.y + shakeData.shakePosition.z - shakeData.shakeLastPosition.x - shakeData.shakeLastPosition.y - shakeData.shakeLastPosition.z) / diffTime * 10000;
		if (speed > kShakeThreshold)
		{
			[self reset];
			[self drawViewInternally];
			result = YES;
		}
		
		shakeData.shakeLastPosition.x = shakeData.shakePosition.x; 
		shakeData.shakeLastPosition.y = shakeData.shakePosition.y; 
		shakeData.shakeLastPosition.z = shakeData.shakePosition.z;
	}
	return result;
}

#pragma mark -
#pragma mark control methods

- (void)setControlTypeSupported:(PLControlTypeSupported)value
{
	controlTypeSupported = value;
	[self loadControls];
}

- (void)createControls
{
	[self removeControls];

	CGSize size = self.bounds.size;
	CGSize buttonSize = size.width < size.height ? CGSizeMake(MAX(kZoomControlMinWidth, size.width * kZoomControlWidthPercentage), MAX(kZoomControlMinHeight, size.height * kZoomControlHeightPercentage)) : CGSizeMake(MAX(kZoomControlMinWidth, size.height * kZoomControlWidthPercentage), MAX(kZoomControlMinHeight, size.width * kZoomControlHeightPercentage));

	[controlsArray addObject:[PLControlZoomOut controlZoomOutWithView:self position:CGPointMake(size.width - buttonSize.width * 2, size.height - buttonSize.height) size:buttonSize]];
	[controlsArray addObject:[PLControlZoomIn controlZoomInWithView:self position:CGPointMake(size.width - buttonSize.width, size.height - buttonSize.height) size:buttonSize]];
	for(PLControl *control in controlsArray)
		control.delegate = self;
}
		
- (void)executeAction:(PLControl *)control
{
	BOOL isZoomIn = [control isKindOfClass:[PLControlZoomIn class]];
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	float distance = [PLMath distanceBetweenPoints:CGPointMake(0.0f, 0.0f) :CGPointMake(screenSize.width * 2, screenSize.height * 2)] * (isZoomIn ? 1 : -1);
		
	BOOL isCancelable = NO;
	
	if(delegate && [delegate respondsToSelector:@selector(view:shouldRunZooming:isZoomIn:isZoomOut:)])
		isCancelable = [delegate view:self shouldRunZooming:distance isZoomIn:isZoomIn isZoomOut:!isZoomIn];
	
	if(!isCancelable)
	{
		isValidForFov = YES;
		fovDistance = distance;
		[scene.currentCamera addFovWithDistance:fovDistance];
		[self drawView];
		if(delegate && [delegate respondsToSelector:@selector(view:didRunZooming:isZoomIn:isZoomOut:)])
			[delegate view:self didRunZooming:fovDistance isZoomIn:isZoomIn isZoomOut:!isZoomIn];
		isValidForFov = NO;
	}
}

- (void)removeControls
{
	for(PLControl *control in controlsArray)
		[control removeFromView];
	[controlsArray removeAllObjects];
}

- (void)loadControls
{	
	for(PLControl *control in controlsArray)
	{
		if(controlTypeSupported & PLControlTypeSupportedZoom && ([control isKindOfClass:[PLControlZoomIn class]] || [control isKindOfClass:[PLControlZoomOut class]]))
			[control addToView:self];
		else
			[control removeFromView];
	}
	[self changeControlsOrientation];
}

- (void)changeControlsOrientation
{
	if(!controlTypeSupported & PLControlTypeSupportedZoom)
		return;
	
	CGSize size = self.bounds.size;
	if(isDeviceOrientationEnabled)
	{
		NSInteger angle = -1;
		CGPoint pos = CGPointMake(0.0f, 0.0f);
		switch (deviceOrientation)
		{
			case UIDeviceOrientationUnknown:
			case UIDeviceOrientationPortrait:
				angle = 0;
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				angle = 180;
				break;
			case UIDeviceOrientationLandscapeLeft:
				angle = 90;
				break;
			case UIDeviceOrientationLandscapeRight:
				angle = -90;
				break;
		}
		
		if(angle != -1)
		{
			for(PLControl *control in controlsArray)
				control.isVisible = NO;
			for(PLControl *control in controlsArray)
			{
				switch (deviceOrientation)
				{
					case UIDeviceOrientationUnknown:
					case UIDeviceOrientationPortrait:
						if([control isKindOfClass:[PLControlZoomOut class]])
							pos = CGPointMake(size.width - control.size.width * 2, size.height - control.size.height);
						else if([control isKindOfClass:[PLControlZoomIn class]])
							pos = CGPointMake(size.width - control.size.width, size.height - control.size.height);
						break;
					case UIDeviceOrientationPortraitUpsideDown:
						if([control isKindOfClass:[PLControlZoomOut class]])
							pos = CGPointMake(control.size.width, 0.0f);
						else if([control isKindOfClass:[PLControlZoomIn class]])
							pos = CGPointMake(0.0f, 0.0f);
						break;
					case UIDeviceOrientationLandscapeLeft:
						if([control isKindOfClass:[PLControlZoomOut class]])
							pos = CGPointMake(0.0f, size.height - control.size.width * 2);
						else if([control isKindOfClass:[PLControlZoomIn class]])
							pos = CGPointMake(0.0f, size.height - control.size.width);
						break;
					case UIDeviceOrientationLandscapeRight:
						if([control isKindOfClass:[PLControlZoomOut class]])
							pos = CGPointMake(size.width - control.size.height, control.size.width);
						else if([control isKindOfClass:[PLControlZoomIn class]])
							pos = CGPointMake(size.width - control.size.height, 0.0f);
						break;
				}
				control.position = pos;
				control.rotate = angle;
			}
			for(PLControl *control in controlsArray)
				control.isVisible = YES;
		}
	}
	else
	{
		for(PLControl *control in controlsArray)
		{
			if([control isKindOfClass:[PLControlZoomOut class]])
				control.position = CGPointMake(size.width - control.size.width * 2, size.height - control.size.height);
			else if([control isKindOfClass:[PLControlZoomIn class]])
				control.position = CGPointMake(size.width - control.size.width, size.height - control.size.height);
		}
	}
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc 
{
	[self reset];
	[self stopAnimation];
	[self deactiveOrientation];
	[self deactiveAccelerometer];
	[self removeControls];
	if(controlsArray)
		[controlsArray release];
	if(scene)
		[scene release];
    if(renderer)
		[renderer release];
    if(referenceAttitude)
        [referenceAttitude release];
	[super dealloc];
}
				
@end
