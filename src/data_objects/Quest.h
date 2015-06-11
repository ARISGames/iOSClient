//
//  Quest.h
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quest : NSObject
{
    long quest_id;
    NSString *name;
    NSString *desc;

    long active_icon_media_id;
    long active_media_id;
    NSString *active_desc;
    NSString *active_notification_type;
    NSString *active_function;
    long active_event_package_id;
    long active_requirement_root_package_id;

    long complete_icon_media_id;
    long complete_media_id;
    NSString *complete_desc;
    NSString *complete_notification_type;
    NSString *complete_function;
    long complete_event_package_id;
    long complete_requirement_root_package_id;

    long sort_index;
}

@property (nonatomic, assign) long quest_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;

@property (nonatomic, assign) long active_icon_media_id;
@property (nonatomic, assign) long active_media_id;
@property (nonatomic, strong) NSString *active_desc;
@property (nonatomic, strong) NSString *active_notification_type;
@property (nonatomic, strong) NSString *active_function;
@property (nonatomic, assign) long active_event_package_id;
@property (nonatomic, assign) long active_requirement_root_package_id;

@property (nonatomic, assign) long complete_icon_media_id;
@property (nonatomic, assign) long complete_media_id;
@property (nonatomic, strong) NSString *complete_desc;
@property (nonatomic, strong) NSString *complete_notification_type;
@property (nonatomic, strong) NSString *complete_function;
@property (nonatomic, assign) long complete_event_package_id;
@property (nonatomic, assign) long complete_requirement_root_package_id;

@property (nonatomic, assign) long sort_index;

- (Quest *) initWithDictionary:(NSDictionary *)dict;

@end
