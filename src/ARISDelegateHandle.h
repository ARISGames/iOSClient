//
//  ARISDelegateHandle.h
//  ARIS
//
//  Created by Phil Dougherty on 3/4/14.
//
//

// This is not a delegateHandle"r", it is a "handle". As in "resource handle".
//
// This is different from traditional resource handles (a la C++) in that
// we're not alloc/deallocing anything.
//
// It is intended as a way to retract delegation from an object that is NOT
// being deallocated- eg ARISMediaLoader, hopefully eventually AppServices.
//
// An example for illustration:
// ARISMediaView (AMV) is alloc'd, wants to delegate loading of media to
// ARISMediaLoader (AML). AML holds an array of media being loaded with the
// delegates to alert of said media's progress.
// Let's say during the load, the AMV is dealloc'd. AML has no way to know,
// and now has a stale pointer that it tries to communicate with upon the
// completion of the media's loading.
//
// NOW, AMV instead passes AML a delegateHandle instead of a raw pointer to
// itself. Both AML AND AMV hold a reference to this handle. Upon deallocation
// of the AMV, it can 'invalidate' this delegateHandle. The object stays in
// existence in AML's array, but with a "nil" (read "not stale") pointer. Come
// time for AML to alert its delegate of progress, it can safely interact with
// a nil pointer, instead of an invalid one.
//
// One unfortunate caveat of this method is the lack of strongly typed delegate.
// You'll need to cast it every use, and trust that it was created correctly.
// Where's Obj_C templating when you need it...

//************
// PLEASE make sure you read/understand what is going on here before using/changing
// this. Not saying this is the ideal way to handle (<- hah) this problem, so
// if you DO understand, feel free to change. Just be cautious.
//
// <3 Phil 3/4/2014
//************

#import <Foundation/Foundation.h>

@interface ARISDelegateHandle : NSObject
- (id) initWithDelegate:(id)d;
- (id) delegate;
- (void) invalidate;
@end
