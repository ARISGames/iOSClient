//
//  InventoryParserDelegate.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InventoryParserDelegate : NSObject {
	NSMutableArray *inventory;
}

- (InventoryParserDelegate*)initWithInventory:(NSMutableArray *)modelInventory;

@end
