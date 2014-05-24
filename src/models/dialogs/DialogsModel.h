//
//  DialogsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Dialog.h"

@interface DialogsModel : NSObject
{
}

- (Dialog *) dialogForId:(int)dialog_id;
- (void) clearGameData;

@end
