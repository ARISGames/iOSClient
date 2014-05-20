//
//  Plaque.h
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plaque : NSObject 
{
	int      plaque_id;
	NSString *name;
	NSString *desc;
	int      icon_media_id;
   	int	     media_id; 
}

@property(nonatomic, assign) int plaque_id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *desc;
@property(nonatomic, assign) int icon_media_id;
@property(nonatomic, assign) int media_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
