//
//  DNTypeEncoding.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/17.
//

#import "DNTypeEncoding.h"
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#elif TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif


#if !__has_feature(objc_arc)
#error
#endif

// Use pointer as key of encoding string cache (on dart side).
#define DEF_NATIVE_TYPE(name) const char * const native_type_##name = #name;
DEF_NATIVE_TYPE(sint8)
DEF_NATIVE_TYPE(sint16)
DEF_NATIVE_TYPE(sint32)
DEF_NATIVE_TYPE(sint64)
DEF_NATIVE_TYPE(uint8)
DEF_NATIVE_TYPE(uint16)
DEF_NATIVE_TYPE(uint32)
DEF_NATIVE_TYPE(uint64)
DEF_NATIVE_TYPE(float32)
DEF_NATIVE_TYPE(float64)
DEF_NATIVE_TYPE(object)
DEF_NATIVE_TYPE(class)
DEF_NATIVE_TYPE(selector)
DEF_NATIVE_TYPE(block)
DEF_NATIVE_TYPE(char_ptr)
DEF_NATIVE_TYPE(void)
DEF_NATIVE_TYPE(ptr)
DEF_NATIVE_TYPE(bool)
DEF_NATIVE_TYPE(string)

static const char *typeList[] = {
    native_type_sint8,
    native_type_sint16,
    native_type_sint32,
    native_type_sint64,
    native_type_uint8,
    native_type_uint16,
    native_type_uint32,
    native_type_uint64,
    native_type_float32,
    native_type_float64,
    native_type_object,
    native_type_class,
    native_type_selector,
    native_type_block,
    native_type_char_ptr,
    native_type_void,
    native_type_ptr,
    native_type_bool,
    native_type_string
};

const char **
native_all_type_encodings() {
    return typeList;
}

#define SINT(type) do { \
    if (str[0] == @encode(type)[0]) { \
        size_t size = sizeof(type); \
        if (size == 1) { \
            return native_type_sint8; \
        } else if (size == 2) { \
            return native_type_sint16; \
        } else if (size == 4) { \
            return native_type_sint32; \
        } else if (size == 8) { \
            return native_type_sint64; \
        } else { \
            NSLog(@"Unknown size for type %s", #type); \
            abort(); \
        } \
    } \
} while(0)

#define UINT(type) do { \
    if (str[0] == @encode(type)[0]) { \
        size_t size = sizeof(type); \
        if (size == 1) { \
            return native_type_uint8; \
        } else if (size == 2) { \
            return native_type_uint16; \
        } else if (size == 4) { \
            return native_type_uint32; \
        } else if (size == 8) { \
            return native_type_uint64; \
        } else { \
            NSLog(@"Unknown size for type %s", #type); \
            abort(); \
        } \
    } \
} while(0)

#define INT(type) do { \
    SINT(type); \
    UINT(unsigned type); \
} while(0)

#define COND(type, name) do { \
    if (str[0] == @encode(type)[0]) {\
        return name; \
    } \
} while(0)

#define PTR(type) COND(type, native_type_ptr)

const char *DNSizeAndAlignment(const char *str, NSUInteger *sizep, NSUInteger *alignp, long *lenp) {
    const char *out = NSGetSizeAndAlignment(str, sizep, alignp);
    if (lenp) {
        *lenp = out - str;
    }
    while(*out == '}') {
        out++;
    }
    while(isdigit(*out)) {
        out++;
    }
    return out;
}

int DNTypeCount(const char *str) {
    int typeCount = 0;
    while(str && *str) {
        str = DNSizeAndAlignment(str, NULL, NULL, NULL);
        typeCount++;
    }
    return typeCount;
}

int DNTypeLengthWithTypeName(NSString *typeName) {
    if (!typeName) {
        return 0;
    }
    static NSMutableDictionary *_typeLengthDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _typeLengthDict = [[NSMutableDictionary alloc] init];

        #define DN_DEFINE_TYPE_LENGTH(_type) \
        [_typeLengthDict setObject:@(sizeof(_type)) forKey:@#_type];\
        
        DN_DEFINE_TYPE_LENGTH(id);
        DN_DEFINE_TYPE_LENGTH(BOOL);
        DN_DEFINE_TYPE_LENGTH(int);
        DN_DEFINE_TYPE_LENGTH(void);
        DN_DEFINE_TYPE_LENGTH(char);
        DN_DEFINE_TYPE_LENGTH(short);
        DN_DEFINE_TYPE_LENGTH(unsigned short);
        DN_DEFINE_TYPE_LENGTH(unsigned int);
        DN_DEFINE_TYPE_LENGTH(long);
        DN_DEFINE_TYPE_LENGTH(unsigned long);
        DN_DEFINE_TYPE_LENGTH(long long);
        DN_DEFINE_TYPE_LENGTH(unsigned long long);
        DN_DEFINE_TYPE_LENGTH(float);
        DN_DEFINE_TYPE_LENGTH(double);
        DN_DEFINE_TYPE_LENGTH(bool);
        DN_DEFINE_TYPE_LENGTH(size_t);
        DN_DEFINE_TYPE_LENGTH(CGFloat);
        DN_DEFINE_TYPE_LENGTH(CGSize);
        DN_DEFINE_TYPE_LENGTH(CGRect);
        DN_DEFINE_TYPE_LENGTH(CGPoint);
        DN_DEFINE_TYPE_LENGTH(CGVector);
#if TARGET_OS_OSX
        DN_DEFINE_TYPE_LENGTH(NSSize);
        DN_DEFINE_TYPE_LENGTH(NSRect);
        DN_DEFINE_TYPE_LENGTH(NSPoint);
        DN_DEFINE_TYPE_LENGTH(NSEdgeInsets);
#elif TARGET_OS_IOS
        DN_DEFINE_TYPE_LENGTH(UIOffset);
        DN_DEFINE_TYPE_LENGTH(UIEdgeInsets);
#endif
        if (@available(iOS 11.0, macOS 10.15, *)) {
            DN_DEFINE_TYPE_LENGTH(NSDirectionalEdgeInsets);
        }
        DN_DEFINE_TYPE_LENGTH(CGAffineTransform);
        DN_DEFINE_TYPE_LENGTH(NSRange);
        DN_DEFINE_TYPE_LENGTH(NSInteger);
        DN_DEFINE_TYPE_LENGTH(NSUInteger);
        DN_DEFINE_TYPE_LENGTH(Class);
        DN_DEFINE_TYPE_LENGTH(SEL);
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"ptr"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"block"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"NSObject*"];
        [_typeLengthDict setObject:@(sizeof(NSObject *)) forKey:@"NSObject"];
        [_typeLengthDict setObject:@(sizeof(char *)) forKey:@"CString"];
    });
    return [_typeLengthDict[typeName] intValue];
}

NSString *DNTypeEncodeWithTypeName(NSString *typeName) {
    if (!typeName) {
        return nil;
    }
    static NSMutableDictionary *_typeEncodeDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _typeEncodeDict = [[NSMutableDictionary alloc] init];
        #define DN_DEFINE_TYPE_ENCODE_CASE(_type) \
        [_typeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

        DN_DEFINE_TYPE_ENCODE_CASE(id);
        DN_DEFINE_TYPE_ENCODE_CASE(BOOL);
        DN_DEFINE_TYPE_ENCODE_CASE(int);
        DN_DEFINE_TYPE_ENCODE_CASE(void);
        DN_DEFINE_TYPE_ENCODE_CASE(char);
        DN_DEFINE_TYPE_ENCODE_CASE(short);
        DN_DEFINE_TYPE_ENCODE_CASE(unsigned short);
        DN_DEFINE_TYPE_ENCODE_CASE(unsigned int);
        DN_DEFINE_TYPE_ENCODE_CASE(long);
        DN_DEFINE_TYPE_ENCODE_CASE(unsigned long);
        DN_DEFINE_TYPE_ENCODE_CASE(long long);
        DN_DEFINE_TYPE_ENCODE_CASE(unsigned long long);
        DN_DEFINE_TYPE_ENCODE_CASE(float);
        DN_DEFINE_TYPE_ENCODE_CASE(double);
        DN_DEFINE_TYPE_ENCODE_CASE(bool);
        DN_DEFINE_TYPE_ENCODE_CASE(size_t);
        DN_DEFINE_TYPE_ENCODE_CASE(CGFloat);
        DN_DEFINE_TYPE_ENCODE_CASE(CGSize);
        DN_DEFINE_TYPE_ENCODE_CASE(CGRect);
        DN_DEFINE_TYPE_ENCODE_CASE(CGPoint);
        DN_DEFINE_TYPE_ENCODE_CASE(CGVector);
        DN_DEFINE_TYPE_ENCODE_CASE(NSRange);
#if TARGET_OS_OSX
        DN_DEFINE_TYPE_ENCODE_CASE(NSSize);
        DN_DEFINE_TYPE_ENCODE_CASE(NSRect);
        DN_DEFINE_TYPE_ENCODE_CASE(NSPoint);
        DN_DEFINE_TYPE_ENCODE_CASE(NSEdgeInsets);
#elif TARGET_OS_IOS
        DN_DEFINE_TYPE_ENCODE_CASE(UIOffset);
        DN_DEFINE_TYPE_ENCODE_CASE(UIEdgeInsets);
#endif
        if (@available(iOS 11.0, macOS 10.15, *)) {
            DN_DEFINE_TYPE_ENCODE_CASE(NSDirectionalEdgeInsets);
        }
        DN_DEFINE_TYPE_ENCODE_CASE(CGAffineTransform);
        DN_DEFINE_TYPE_ENCODE_CASE(NSInteger);
        DN_DEFINE_TYPE_ENCODE_CASE(NSUInteger);
        DN_DEFINE_TYPE_ENCODE_CASE(Class);
        DN_DEFINE_TYPE_ENCODE_CASE(SEL);
        [_typeEncodeDict setObject:@"^v" forKey:@"ptr"];
        [_typeEncodeDict setObject:@"@?" forKey:@"block"];
        [_typeEncodeDict setObject:@"^@" forKey:@"NSObject*"];
        [_typeEncodeDict setObject:@"@" forKey:@"NSObject"];
        [_typeEncodeDict setObject:@"@" forKey:@"String"];
        [_typeEncodeDict setObject:@"*" forKey:@"CString"];
    });
    return _typeEncodeDict[typeName];
}

// When returns struct encoding, it needs to be freed.
const char *native_type_encoding(const char *str) {
    if (!str || strlen(str) == 0) {
        return native_type_void;
    }
    
    COND(_Bool, native_type_bool);
    SINT(signed char);
    UINT(unsigned char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    COND(float, native_type_float32);
    COND(double, native_type_float64);
    
    if (strcmp(str, "@?") == 0) {
        return native_type_block;
    }
    
    COND(id, native_type_object);
    COND(Class, native_type_class);
    COND(SEL, native_type_selector);
    PTR(void *);
    COND(char *, native_type_char_ptr);
    COND(void, native_type_void);
    
    // Ignore Method Encodings
    switch (*str) {
        case 'r':
        case 'R':
        case 'n':
        case 'N':
        case 'o':
        case 'O':
        case 'V':
            return native_type_encoding(str + 1);
    }
    
    // Struct Type Encodings
    if (*str == '{') {
        return native_struct_encoding(str);
    }
    
    NSLog(@"Unknown encode string %s", str);
    return str;
}

// Returns type encodings whose need to be freed.
const char **native_types_encoding(const char *str, int *count, int startIndex) {
    int argCount = DNTypeCount(str) - startIndex;
    if (argCount <= 0) {
        return nil;
    }
    const char **argTypes = (const char **)malloc(sizeof(char *) * argCount);
    if (argTypes == NULL) {
        return argTypes;
    }
    
    int i = -startIndex;
    if (!str || !*str) {
        free(argTypes);
        return nil;
    }
    while (str && *str) {
        const char *next = DNSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0 && i < argCount) {
            const char *argType = native_type_encoding(str);
            if (argType) {
                argTypes[i] = argType;
            } else {
                if (count) {
                    *count = -1;
                }
                free(argTypes);
                return nil;
            }
        }
        i++;
        str = next;
    }
    
    if (count) {
        *count = argCount;
    }
    
    return argTypes;
}

// Returns struct encoding which will be freed.
const char *native_struct_encoding(const char *encoding) {
    NSUInteger size, align;
    long length;
    DNSizeAndAlignment(encoding, &size, &align, &length);
    NSString *str = [NSString stringWithUTF8String:encoding];
    const char *temp = [str substringWithRange:NSMakeRange(0, length)].UTF8String;
    if (!temp) {
        return nil;
    }
    int structNameLength = 0;
    // cut "struct="
    while (*temp && *temp != '=') {
        temp++;
        structNameLength++;
    }
    int elementCount = 0;
    const char **elements = native_types_encoding(temp + 1, &elementCount, 0);
    if (!elements) {
        return nil;
    }
    NSMutableString *structType = [NSMutableString stringWithFormat:@"%@", [str substringToIndex:structNameLength + 1]];
    for (int i = 0; i < elementCount; i++) {
        if (i != 0) {
            [structType appendString:@","];
        }
        const char *element = elements[i];
        [structType appendFormat:@"%@", [NSString stringWithUTF8String:element]];
        // `structType` contains other structs, we should free nested struct types.
        if (*element == '{') {
            free((void *)element);
        }
    }
    [structType appendString:@"}"];
    free(elements);
    // Malloc struct type, it will be freed on dart side.
    const char *encodeSource = structType.UTF8String;
    size_t typeLength = strlen(encodeSource) + 1;
    char *typePtr = (char *)malloc(sizeof(char) * typeLength);
    strlcpy(typePtr, encodeSource, typeLength);
    return typePtr;
}
