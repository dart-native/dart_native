//
//  NSString+DartNative.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/11.
//

#import "NSString+DartNative.h"
#include <stdlib.h>

/// Returns UTF16 data for NSString by skipping the BOM.
/// - Parameters:
///   - string: An instance of NSString
///   - length: Length of UTF16 data is returned by this out parameter
const uint16_t *native_convert_nsstring_to_utf16(NSString *string, uint64_t * length) {
    NSData *data = [string dataUsingEncoding:NSUTF16StringEncoding];
    // UTF16, 2-byte per unit
    *length = data.length / 2;
    uint16_t *result = (uint16_t *)data.bytes;
    if (*result == 0xFEFF || *result == 0xFFFE) { // skip BOM
        result++;
        *length = *length - 1;
    }
    return result;
}



@implementation NSString (DartNative)

/// Return data for NSString: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
- (const uint16_t *)dn_UTF16Data {
    uint64_t length = 0;
    const uint16_t *utf16BufferPtr = native_convert_nsstring_to_utf16(self, &length);
    size_t size = sizeof(uint16_t) * (size_t)length;
    const size_t lengthDataSize = 4;
    // free memory on dart side.
    uint16_t *dataPtr = (uint16_t *)malloc(size + sizeof(uint16_t) * lengthDataSize);
    memcpy(dataPtr + lengthDataSize, utf16BufferPtr, size);
    uint16_t lengthData[4] = {
        static_cast<uint16_t>(length >> 48 & 0xffff),
        static_cast<uint16_t>(length >> 32 & 0xffff),
        static_cast<uint16_t>(length >> 16 & 0xffff),
        static_cast<uint16_t>(length & 0xffff)
    };
    memcpy(dataPtr, lengthData, sizeof(uint16_t) * lengthDataSize);
    return dataPtr;
}

/// Return a NSString for utf-16 data
/// @param codeUnits data format: [--dataLength(64bit--)][--dataContent(utf16 without BOM)--]
+ (instancetype)dn_stringWithUTF16String:(const unichar *)codeUnits {
    if (!codeUnits) {
        return nil;
    }
    // First four uint16_t is for data length.
    const NSUInteger lengthDataSize = 4;
    uint64_t length = codeUnits[0];
    for (int i = 1; i < lengthDataSize; i++) {
        length <<= 16;
        length |= codeUnits[i];
    }
    NSString *result = [NSString stringWithCharacters:codeUnits + lengthDataSize length:(NSUInteger)length];
    free((void *)codeUnits); // Malloc data on dart side, need free here.
    return result;
}

@end


