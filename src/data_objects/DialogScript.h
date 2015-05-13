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
  long dialog_script_id;
  long dialog_id;
  long dialog_character_id;
  NSString *text;
  long event_package_id;
}

@property(nonatomic, assign) long dialog_script_id;
@property(nonatomic, assign) long dialog_id;
@property(nonatomic, assign) long dialog_character_id;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) long event_package_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
