//
//  Group.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "InstantiableProtocol.h"

@interface Group : NSObject <InstantiableProtocol>
{
    long group_id;
    NSString *name;
}

@property (nonatomic, assign) long group_id;
@property (nonatomic, strong) NSString *name;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end

