//
//  DialogOption.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogOption : NSObject
{
  long dialog_option_id;
  long dialog_id;
  long parent_dialog_script_id;
  NSString *prompt;
  NSString *link_type;
  long link_id;
  NSString *link_info;
  long sort_index;
  long requirement_root_package_id;
}

@property(nonatomic, assign) long dialog_option_id;
@property(nonatomic, assign) long dialog_id;
@property(nonatomic, assign) long parent_dialog_script_id;
@property(nonatomic, strong) NSString *prompt;
@property(nonatomic, strong) NSString *link_type;
@property(nonatomic, assign) long link_id;
@property(nonatomic, strong) NSString *link_info;
@property(nonatomic, assign) long sort_index;
@property(nonatomic, assign) long requirement_root_package_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
