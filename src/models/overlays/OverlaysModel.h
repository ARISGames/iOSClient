//
//  OverlaysModel.h
//  ARIS
//
//  Created by Justin Moeller on 3/7/14.
//
//

#import <Foundation/Foundation.h>

@interface OverlaysModel : NSObject
{
    NSArray *overlays;
}

@property (nonatomic, strong) NSArray *overlays;

- (void) clearData;

@end
