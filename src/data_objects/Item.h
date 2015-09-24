//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantiableProtocol.h"

@interface Item : NSObject <InstantiableProtocol>
{
  long item_id;
  NSString *name;
  NSString *desc;
  long icon_media_id;
  long media_id;
  BOOL droppable;
  BOOL destroyable;
  long max_qty_in_inventory;
  long weight;
  NSString *url;
  NSString *type; //NORMAL, ATRIB, HIDDEN, URL
  BOOL delta_notification;
}

@property (nonatomic, assign) long item_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) long icon_media_id;
@property (nonatomic, assign) long media_id;
@property (nonatomic, assign) BOOL droppable;
@property (nonatomic, assign) BOOL destroyable;
@property (nonatomic, assign) long max_qty_in_inventory;
@property (nonatomic, assign) long weight;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL delta_notification;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end

