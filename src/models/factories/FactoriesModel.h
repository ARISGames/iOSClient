//
//  FactoriesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Factory.h"

@interface FactoriesModel : NSObject
{
}

- (Factory *) factoryForId:(long)factory_id;
- (void) requestFactories;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end
