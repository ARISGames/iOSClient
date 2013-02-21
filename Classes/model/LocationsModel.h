//
//  LocationsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/20/13.
//
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface LocationsModel : NSObject
{
    NSArray *currentLocations;
}

@property(nonatomic, strong) NSArray *currentLocations;

-(void)clearData;
-(int)modifyQuantity:(int)quantityModifier forLocationId:(int)locationId;
-(Location *)locationForId:(int)itemId;

@end
