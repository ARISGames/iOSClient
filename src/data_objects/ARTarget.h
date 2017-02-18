//
//  ARTarget.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "InstantiableProtocol.h"

@interface ARTarget : NSObject
{
    long ar_target_id;
    NSString *name;
    long vuforia_index;
}

@property (nonatomic, assign) long ar_target_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) long vuforia_index;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end

