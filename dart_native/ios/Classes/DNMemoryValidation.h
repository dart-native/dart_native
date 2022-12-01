//
//  DNMemoryValidation.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/9.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"

NS_ASSUME_NONNULL_BEGIN

/// Returens true if a pointer is a tagged pointer
/// @param ptr is the pointer to check
DN_EXTERN bool objc_isTaggedPointer(const void *ptr);

/// Returns true if a pointer is valid
/// @param pointer is the pointer to check
DN_EXTERN bool native_isValidPointer(const void *pointer);

NS_ASSUME_NONNULL_END
