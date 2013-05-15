//
//  UIImage+Scale.h
//  ARIS
//
//  Created by Philip Dougherty on 7/11/11.
//  Copyright 2011 UW Madison. All rights reserved.
//
//  From the following site:
//  http://iphonedevelopertips.com/graphics/how-to-scale-an-image-using-an-objective-c-category.html
//

#import <Foundation/Foundation.h>


@interface UIImage (scale)

-(UIImage *)scaleToSize:(CGSize)size;

@end
