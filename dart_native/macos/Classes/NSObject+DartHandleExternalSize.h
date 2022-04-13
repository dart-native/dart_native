//
//  NSObject+DartHandleExternalSize.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DartHandleExternalSize)

/// Size of NSObject instance on heap.
- (size_t)dn_objectSize;

@end

@interface NSArray (DartHandleExternalSize)

/// Size of NSArray instance on heap.
- (size_t)dn_objectSize;

@end

@interface NSDictionary (DartHandleExternalSize)

/// Size of NSDictionary instance on heap.
- (size_t)dn_objectSize;

@end

@interface NSSet (DartHandleExternalSize)

/// Size of NSSet instance on heap.
- (size_t)dn_objectSize;

@end

NS_ASSUME_NONNULL_END
