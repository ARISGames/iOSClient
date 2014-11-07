//
//  NoteComment.h
//  ARIS
//
//  Created by Phil Dougherty on 1/23/14.
//
//

#import <Foundation/Foundation.h>

@interface NoteComment : NSObject
{
    int note_comment_id;
    int note_id;
    int user_id;
    NSString *name;
    NSString *desc;
    NSDate *created; 
}

@property(nonatomic, assign) int note_comment_id;
@property(nonatomic, assign) int note_id;
@property(nonatomic, assign) int user_id;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *desc;
@property(nonatomic, retain) NSDate *created; 

- (id) initWithDictionary:(NSDictionary *)dict;

@end
