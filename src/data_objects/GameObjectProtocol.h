//
//  GameObjectProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 4/25/13.
//
//

#import <Foundation/Foundation.h>
#import "GameObjectViewController.h"

@protocol GameObjectProtocol <NSObject>

- (NSString *) name;
- (int) icon_media_id;

- (NSString *) description;

@end
