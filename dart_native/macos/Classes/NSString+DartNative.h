//
//  NSString+DartNative.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/11.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"

NS_ASSUME_NONNULL_BEGIN

/// Returns UTF16 data for NSString by skipping the BOM.
/// - Parameters:
///   - string: An instance of NSString
///   - length: Length of UTF16 data is returned by this out parameter
DN_EXTERN const uint16_t *native_convert_nsstring_to_utf16(NSString *string, uint64_t *length);

@interface NSString (DartNative)

/// Return data for NSString: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
- (const uint16_t *)dn_UTF16Data;

/// Return a NSString for utf-16 data
/// @param codeUnits data format: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
+ (instancetype)dn_stringWithUTF16String:(const unichar *)codeUnits;

@end

NS_ASSUME_NONNULL_END
