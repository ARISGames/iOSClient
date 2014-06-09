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
	int dialog_id;
	NSString *name;
   	NSString *desc; 
   	int	icon_media_id;
	int root_script_id;
}

@property(nonatomic, assign) int dialog_id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *desc;
@property(nonatomic, assign) int icon_media_id;
@property(nonatomic, assign) int root_script_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
