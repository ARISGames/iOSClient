//
//  Plaque.h
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantiableProtocol.h"

@interface Plaque : NSObject <InstantiableProtocol>
{
  long plaque_id;
  NSString *name;
  NSString *desc;
  long icon_media_id;
  long media_id;
  long event_package_id;
  BOOL back_button_enabled;
  NSString *continue_function;
  BOOL full_screen;
}

@property(nonatomic, assign) long plaque_id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *desc;
@property(nonatomic, assign) long icon_media_id;
@property(nonatomic, assign) long media_id;
@property(nonatomic, assign) long event_package_id;
@property(nonatomic, assign) BOOL back_button_enabled;
@property(nonatomic, strong) NSString *continue_function;
@property(nonatomic, assign) BOOL full_screen;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end

