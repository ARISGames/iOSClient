//
//  DialogCharacter.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogCharacter : NSObject
{
  int dialog_character_id;
  NSString *name;
  NSString *title;
  int media_id;
}

@property(nonatomic, assign) int dialog_character_id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) int media_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end

