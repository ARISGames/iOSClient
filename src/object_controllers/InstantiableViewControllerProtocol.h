//
//  InstantiableViewControllerProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 4/29/13.
//
//


@class Instance;
@protocol InstantiableViewControllerProtocol
- (Instance *) instance;
@end
@protocol InstantiableViewControllerDelegate
- (void) instantiableViewControllerRequestsDismissal:(id<InstantiableViewControllerProtocol>)ivc;
@end

