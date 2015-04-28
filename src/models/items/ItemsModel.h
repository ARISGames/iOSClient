//
//  ItemsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface ItemsModel : NSObject
{
}

- (NSArray *) items;
- (Item *) itemForId:(long)item_id;
- (void) requestItems;
- (void) clearGameData;

@end
