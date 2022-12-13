//
//  DNFFIHelper.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import "DNFFIHelper.h"
#import "DNTypeEncoding.h"

#if !__has_feature(objc_arc)
#error
#endif

@interface DNFFIHelper ()

@property (nonatomic) NSMutableArray *allocations;

@end

@implementation DNFFIHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        _allocations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (ffi_type *)ffiTypeForStructEncode:(const char *)str {
    NSUInteger size, align;
    long length;
    DNSizeAndAlignment(str, &size, &align, &length);
    ffi_type *structType = [self _allocate:sizeof(*structType)];
    structType->type = FFI_TYPE_STRUCT;
    
    const char *temp = [[[NSString stringWithUTF8String:str] substringWithRange:NSMakeRange(0, length)] UTF8String];
    if (!temp) {
        return nil;
    }
    // cut "struct="
    while (*temp && *temp != '=') {
        temp++;
    }
    int elementCount = 0;
    ffi_type **elements = [self typesWithEncodeString:temp + 1 getCount:&elementCount startIndex:0 nullAtEnd:YES];
    if (!elements) {
        return nil;
    }
    structType->elements = elements;
    return structType;
}

#define SINT(type) do { \
    if (str[0] == @encode(type)[0]) { \
        if (sizeof(type) == 1) { \
            return &ffi_type_sint8; \
        } else if (sizeof(type) == 2) { \
            return &ffi_type_sint16; \
        } else if (sizeof(type) == 4) { \
            return &ffi_type_sint32; \
        } else if (sizeof(type) == 8) { \
            return &ffi_type_sint64; \
        } else { \
            NSLog(@"Unknown size for type %s", #type); \
            abort(); \
        } \
    } \
} while(0)

#define UINT(type) do { \
    if (str[0] == @encode(type)[0]) { \
        if (sizeof(type) == 1) { \
            return &ffi_type_uint8; \
        } else if (sizeof(type) == 2) { \
            return &ffi_type_uint16; \
        } else if (sizeof(type) == 4) { \
            return &ffi_type_uint32; \
        } else if (sizeof(type) == 8) { \
            return &ffi_type_uint64; \
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
        return &ffi_type_ ## name; \
    } \
} while(0)

#define PTR(type) COND(type, pointer)

- (ffi_type *)ffiTypeForEncode:(const char *)str {
    SINT(_Bool);
    SINT(signed char);
    UINT(unsigned char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    
    PTR(id);
    PTR(Class);
    PTR(SEL);
    PTR(void *);
    PTR(char *);
    
    COND(float, float);
    COND(double, double);
    COND(void, void);
    
    // Ignore Method Encodings
    switch (*str) {
        case 'r':
        case 'R':
        case 'n':
        case 'N':
        case 'o':
        case 'O':
        case 'V':
            return [self ffiTypeForEncode:str + 1];
    }
    
    // Struct Type Encodings
    if (*str == '{') {
        ffi_type *structType = [self ffiTypeForStructEncode:str];
        return structType;
    }
    
    NSLog(@"Unknown encode string %s", str);
    return nil;
}

- (ffi_type **)argsWithEncodeString:(const char *)str getCount:(int *)outCount {
    // 第一个是返回值，需要排除
    return [self typesWithEncodeString:str getCount:outCount startIndex:1];
}

- (ffi_type **)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start {
    return [self typesWithEncodeString:str getCount:outCount startIndex:start nullAtEnd:NO];
}

- (ffi_type **)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start nullAtEnd:(BOOL)nullAtEnd {
    int argCount = DNTypeCount(str) - start;
    ffi_type **argTypes = [self _allocate:(argCount + (nullAtEnd ? 1 : 0)) * sizeof(*argTypes)];
    
    int i = -start;
    while(str && *str) {
        const char *next = DNSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0 && i < argCount) {
            ffi_type *argType = [self ffiTypeForEncode:str];
            if (argType) {
                argTypes[i] = argType;
            } else {
                if (outCount) {
                    *outCount = -1;
                }
                return nil;
            }
        }
        i++;
        str = next;
    }
    
    if (nullAtEnd) {
        argTypes[argCount] = NULL;
    }
    
    if (outCount) {
        *outCount = argCount;
    }
    
    return argTypes;
}


/// MARK: Private Method

- (void *)_allocate:(size_t)size {
    NSMutableData *data = [NSMutableData dataWithLength:size];
    [self.allocations addObject:data];
    return data.mutableBytes;
}

@end
