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
  int dialog_option_id;
  int dialog_id; 
  int parent_dialog_script_id;
  NSString *prompt;
  NSString *link_type;
  int link_id;
  int sort_index; 
}

@property(nonatomic, assign) int dialog_option_id;
@property(nonatomic, assign) int dialog_id;
@property(nonatomic, assign) int parent_dialog_script_id;
@property(nonatomic, strong) NSString *prompt;
@property(nonatomic, strong) NSString *link_type;
@property(nonatomic, assign) int link_id;
@property(nonatomic, assign) int sort_index;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
