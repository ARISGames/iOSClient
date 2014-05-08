//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

@interface Item : NSObject <GameObjectProtocol>
{
  int item_id;
  NSString *name;
  NSString *desc;
  int icon_media_id;
  int media_id; 
  BOOL droppable;
  BOOL destroyable; 
  int max_qty_in_inventory;
  int weight;
  NSString *url;
  NSString *type; //NORMAL, ATRIB, URL
}

@property (nonatomic, assign) int item_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) int icon_media_id;
@property (nonatomic, assign) int media_id;
@property (nonatomic, assign) BOOL droppable;
@property (nonatomic, assign) BOOL destroyable;
@property (nonatomic, assign) int max_qty_in_inventory;
@property (nonatomic, assign) int weight;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *type;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
