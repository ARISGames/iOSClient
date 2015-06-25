//
//  EventPackage.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "InstantiableProtocol.h"

@interface EventPackage : NSObject <InstantiableProtocol> //joke class
{
  long event_package_id;
}

@property(readwrite, assign) long event_package_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
