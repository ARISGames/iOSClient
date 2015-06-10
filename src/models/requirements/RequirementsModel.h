//
//  RequirementsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Requirement.h"

@interface RequirementsModel : NSObject

- (RequirementRootPackage *) requirementRootPackageForId:(long)requirement_root_package_id;
- (RequirementAndPackage *) requirementAndPackageForId:(long)requirement_and_package_id;
- (RequirementAtom *) requirementAtomForId:(long)requirement_atom_id;
- (BOOL) evaluateRequirementRoot:(long)requirement_root_package_id;
- (void) requestRequirements;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end
