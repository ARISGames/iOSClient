//
//  RequestCD.h
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RequestCD : NSManagedObject
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSData *body;
@end

