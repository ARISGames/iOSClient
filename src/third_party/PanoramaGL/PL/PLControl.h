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

#import <UIKit/UIButton.h>
#import "PLMath.h"
#import "PLControlDelegate.h"
#import "PLResources.h"

@class PLViewBase;

@interface PLControl : NSObject
{
	CGPoint position;
	CGSize size;
	PLResourceId image, overImage;
	float alpha;
	BOOL isVisible, isValid;
	
	UIButton *button;
	PLViewBase *view;
	
	NSInteger rotate;
	
	NSObject<PLControlDelegate> *delegate;
}

@property(nonatomic) CGPoint position;
@property(nonatomic) CGSize size;
@property(nonatomic) PLResourceId image, overImage;
@property(nonatomic) float alpha;
@property(nonatomic) BOOL isVisible;
@property(nonatomic, readonly) BOOL isValid;
@property(nonatomic) NSInteger rotate;
@property(nonatomic, assign) NSObject<PLControlDelegate> *delegate;

- (id)initWithView:(PLViewBase *)view position:(CGPoint)positionValue size:(CGSize)sizeValue image:(PLResourceId)imageId overImage:(PLResourceId)overImageId;
+ (PLControl *)controlWithView:(PLViewBase *)view position:(CGPoint)positionValue size:(CGSize)sizeValue image:(PLResourceId)imageId overImage:(PLResourceId)overImageId;

- (void)addToView:(PLViewBase *)view;
- (void)removeFromView;

@end
