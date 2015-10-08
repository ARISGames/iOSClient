//
//  FactoriesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Factory.h"

@interface FactoriesModel : ARISModel
{
}

- (Factory *) factoryForId:(long)factory_id;
- (void) requestFactories;

@end

