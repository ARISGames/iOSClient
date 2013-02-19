//
//  QuestsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>

@interface QuestsModel : NSObject
{
    NSArray *currentActiveQuests;
    NSArray *currentCompletedQuests;
    int totalQuestsInGame;
}

@property(nonatomic, strong) NSArray *currentActiveQuests;
@property(nonatomic, strong) NSArray *currentCompletedQuests;
@property(nonatomic) int totalQuestsInGame;

-(void)clearData;

@end
