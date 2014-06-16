//
//  DialogScript.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogScript : NSObject
{
  int dialog_script_id;
  int parent_dialog_script_id;
  int dialog_character_id;
  NSString *text;
  int sort_index;
}

@property(nonatomic, assign) int dialog_script_id;
@property(nonatomic, assign) int parent_dialog_script_id;
@property(nonatomic, assign) int dialog_character_id;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) int sort_index;

- (id) initWithDictionary:(NSDictionary *)dict;

@end

