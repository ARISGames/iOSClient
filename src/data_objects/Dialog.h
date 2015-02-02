//
//  Dialog.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantiableProtocol.h"

@interface Dialog : NSObject <InstantiableProtocol>
{
  long dialog_id;
  NSString *name;
  NSString *desc;
  long icon_media_id;
  long intro_dialog_script_id;
}

@property(nonatomic, assign) long dialog_id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *desc;
@property(nonatomic, assign) long icon_media_id;
@property(nonatomic, assign) long intro_dialog_script_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
