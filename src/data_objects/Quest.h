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
    int quest_id;
    NSString *name;
    NSString *desc; 
    
    int active_icon_media_id;
    int active_media_id; 
    NSString *active_desc;
    NSString *active_notification_type; 
    NSString *active_function;  
    int active_event_package_id;
    
    int complete_icon_media_id;
    int complete_media_id; 
    NSString *complete_desc;
    NSString *complete_notification_type; 
    NSString *complete_function;   
    int complete_event_package_id;
    
    int sort_index;
}

@property (nonatomic, assign) int quest_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc; 
    
@property (nonatomic, assign) int active_icon_media_id;
@property (nonatomic, assign) int active_media_id; 
@property (nonatomic, strong) NSString *active_desc;
@property (nonatomic, strong) NSString *active_notification_type; 
@property (nonatomic, strong) NSString *active_function;  
@property (nonatomic, assign) int active_event_package_id;  
    
@property (nonatomic, assign) int complete_icon_media_id;
@property (nonatomic, assign) int complete_media_id; 
@property (nonatomic, strong) NSString *complete_desc;
@property (nonatomic, strong) NSString *complete_notification_type; 
@property (nonatomic, strong) NSString *complete_function;   
@property (nonatomic, assign) int complete_event_package_id;   
    
@property (nonatomic, assign) int sort_index;

- (Quest *) initWithDictionary:(NSDictionary *)dict;

@end
