//
//  ARISServiceResult.h
//  ARIS
//
//  Created by Phil Dougherty on 2/7/14.
//
//

#import <Foundation/Foundation.h>

@interface ARISServiceResult : NSObject
{
    NSObject *resultData;
    NSDictionary *userInfo;
   	NSMutableData *asyncData; 
    NSURLRequest *urlRequest;
    NSURLConnection *connection; 
    id __unsafe_unretained handler;
    SEL successSelector; 
    SEL failSelector;   
    BOOL retryOnFail;
    
    NSDate *start;
    NSTimeInterval time;
};
@property (nonatomic, strong) NSObject *resultData;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSMutableData *asyncData;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) id handler;
@property (nonatomic, assign) SEL successSelector;
@property (nonatomic, assign) SEL failSelector;
@property (nonatomic, assign) BOOL retryOnFail;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, assign) NSTimeInterval time;

@end
