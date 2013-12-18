//
//  Media.h
//  ARIS
//
//  Created by Phil Dougherty on 12/17/13.
//
//

#import <Foundation/Foundation.h>
@class MediaCD;

@interface Media : NSObject
{
    int gameId;
    int mediaId;
    NSURL *localURL;
    NSURL *remoteURL;
    NSData *data; 
}

@property (readwrite, assign) int gameId;
@property (readwrite, assign) int mediaId;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) NSData *data;

- (id) initWithMediaCD:(MediaCD *)mcd;
- (NSString *) fileExtension;
- (NSString *) type;

@end
