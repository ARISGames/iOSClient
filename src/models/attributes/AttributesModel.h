//
//  AttributesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface AttributesModel : NSObject
{
    NSArray *currentAttributes;
}

@property(nonatomic, strong) NSArray *currentAttributes;

-(void)clearData;
-(int)removeItemFromAttributes:(Item*)item qtyToRemove:(int)qty;
-(int)addItemToAttributes:(Item*)item qtyToAdd:(int)qty;
-(Item *)attributesItemForId:(int)itemId;

@end
