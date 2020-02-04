//
//  DNFFIHelper.m
//  dart_native
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import "DNFFIHelper.h"

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
    while(str && *str)
    {
        str = DNSizeAndAlignment(str, NULL, NULL, NULL);
        typeCount++;
    }
    return typeCount;
}

int DNTypeLengthWithTypeName(NSString *typeName) {
    if (!typeName) return 0;
    static NSMutableDictionary *_typeLengthDict;
    if (!_typeLengthDict) {
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
        DN_DEFINE_TYPE_LENGTH(UIOffset);
        DN_DEFINE_TYPE_LENGTH(UIEdgeInsets);
        if (@available(iOS 11.0, *)) {
            DN_DEFINE_TYPE_LENGTH(NSDirectionalEdgeInsets);
        }
        DN_DEFINE_TYPE_LENGTH(CGAffineTransform);
        DN_DEFINE_TYPE_LENGTH(NSRange);
        DN_DEFINE_TYPE_LENGTH(NSInteger);
        DN_DEFINE_TYPE_LENGTH(NSUInteger);
        DN_DEFINE_TYPE_LENGTH(Class);
        DN_DEFINE_TYPE_LENGTH(SEL);
        [_typeLengthDict setObject:@(sizeof(SEL)) forKey:@"Selector"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"ptr"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"block"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"NSObject*"];
        [_typeLengthDict setObject:@(sizeof(NSObject *)) forKey:@"NSObject"];
        [_typeLengthDict setObject:@(sizeof(char *)) forKey:@"CString"];
    }
    return [_typeLengthDict[typeName] intValue];
}

NSString *DNTypeEncodeWithTypeName(NSString *typeName) {
    if (!typeName) return nil;
    static NSMutableDictionary *_typeEncodeDict;
    if (!_typeEncodeDict) {
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
        DN_DEFINE_TYPE_ENCODE_CASE(UIOffset);
        DN_DEFINE_TYPE_ENCODE_CASE(UIEdgeInsets);
        if (@available(iOS 11.0, *)) {
            DN_DEFINE_TYPE_ENCODE_CASE(NSDirectionalEdgeInsets);
        }
        DN_DEFINE_TYPE_ENCODE_CASE(CGAffineTransform);
        DN_DEFINE_TYPE_ENCODE_CASE(NSInteger);
        DN_DEFINE_TYPE_ENCODE_CASE(NSUInteger);
        DN_DEFINE_TYPE_ENCODE_CASE(Class);
        DN_DEFINE_TYPE_ENCODE_CASE(SEL);
        [_typeEncodeDict setObject:@"Selector" forKey:@"Selector"];
        [_typeEncodeDict setObject:@"^v" forKey:@"ptr"];
        [_typeEncodeDict setObject:@"@?" forKey:@"block"];
        [_typeEncodeDict setObject:@"^@" forKey:@"NSObject*"];
        [_typeEncodeDict setObject:@"@" forKey:@"NSObject"];
        [_typeEncodeDict setObject:@"*" forKey:@"CString"];
    }
    return _typeEncodeDict[typeName];
}

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
    
    // cut "struct="
    while (temp && *temp && *temp != '=') {
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

- (ffi_type *)ffiTypeForEncode:(const char *)str {
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
        if (str[0] == @encode(type)[0]) \
        return &ffi_type_ ## name; \
    } while(0)
    
    #define PTR(type) COND(type, pointer)
    
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
    while(str && *str)
    {
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


#pragma mark - Private Method

- (void *)_allocate:(size_t)howmuch {
    NSMutableData *data = [NSMutableData dataWithLength:howmuch];
    [self.allocations addObject:data];
    return data.mutableBytes;
}

@end
