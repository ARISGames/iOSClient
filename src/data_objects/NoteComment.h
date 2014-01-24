//
//  NoteComment.h
//  ARIS
//
//  Created by Phil Dougherty on 1/23/14.
//
//

#import <Foundation/Foundation.h>

@class Player;

@interface NoteComment : NSObject
{
    int noteId; 
    int commentId;
    Player *owner;
    NSString *text;
    NSDate *created; 
}

@property (nonatomic, assign) int noteId;
@property (nonatomic, assign) int commentId;
@property (nonatomic, strong) Player *owner;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *created;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
