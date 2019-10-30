//
//  DOFFIHelper.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import "DOFFIHelper.h"

const char *DOSizeAndAlignment(const char *str, NSUInteger *sizep, NSUInteger *alignp, long *lenp) {
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

int DOTypeCount(const char *str) {
    int typeCount = 0;
    while(str && *str)
    {
        str = DOSizeAndAlignment(str, NULL, NULL, NULL);
        typeCount++;
    }
    return typeCount;
}

void DOStoreValueToPointer(id result, void *pointer, const char *encoding) {
    if ([result isKindOfClass:NSNumber.class]) {
        NSNumber *num = result;
        switch (encoding[0]) {
            case 'c':
                *(char *)pointer = num.charValue;
                break;
            case 'i':
                *(int *)pointer = num.intValue;
                break;
            case 's':
                *(short *)pointer = num.shortValue;
                break;
            case 'l':
                *(long *)pointer = num.longValue;
                break;
            case 'q':
                *(long long *)pointer = num.longLongValue;
                break;
            case 'C':
                *(unsigned char *)pointer = num.unsignedCharValue;
                break;
            case 'I':
                *(unsigned int *)pointer = num.unsignedIntValue;
                break;
            case 'S':
                *(unsigned short *)pointer = num.unsignedShortValue;
                break;
            case 'L':
                *(unsigned long *)pointer = num.unsignedLongValue;
                break;
            case 'Q':
                *(unsigned long long *)pointer = num.unsignedLongLongValue;
                break;
            case 'f':
                *(float *)pointer = num.floatValue;
                break;
            case 'd':
                *(double *)pointer = num.doubleValue;
                break;
            case 'B':
                *(_Bool *)pointer = num.boolValue;
                break;
            case '^':
            case '@':
                *(void **)pointer = (__bridge void *)(num);
                break;
            default:
                break;
        }
    }
    else if ([result isKindOfClass:NSString.class]) {
        NSString *string = result;
        switch (encoding[0]) {
            case 'c':
                *(char *)pointer = string.UTF8String[0];
                break;
            case '*':
                *(char **)pointer = (char *)string.UTF8String;
                break;
            case '^':
            case '@':
                *(void **)pointer = (__bridge void *)(string);
                break;
            default:
                break;
        }
    }
    else {
        *(void **)pointer = (__bridge void *)(result);
    }
}

int DOTypeLengthWithTypeName(NSString *typeName) {
    if (!typeName) return 0;
    static NSMutableDictionary *_typeLengthDict;
    if (!_typeLengthDict) {
        _typeLengthDict = [[NSMutableDictionary alloc] init];
        
        #define DO_DEFINE_TYPE_LENGTH(_type) \
        [_typeLengthDict setObject:@(sizeof(_type)) forKey:@#_type];\

        DO_DEFINE_TYPE_LENGTH(id);
        DO_DEFINE_TYPE_LENGTH(BOOL);
        DO_DEFINE_TYPE_LENGTH(int);
        DO_DEFINE_TYPE_LENGTH(void);
        DO_DEFINE_TYPE_LENGTH(char);
        DO_DEFINE_TYPE_LENGTH(short);
        DO_DEFINE_TYPE_LENGTH(unsigned short);
        DO_DEFINE_TYPE_LENGTH(unsigned int);
        DO_DEFINE_TYPE_LENGTH(long);
        DO_DEFINE_TYPE_LENGTH(unsigned long);
        DO_DEFINE_TYPE_LENGTH(long long);
        DO_DEFINE_TYPE_LENGTH(unsigned long long);
        DO_DEFINE_TYPE_LENGTH(float);
        DO_DEFINE_TYPE_LENGTH(double);
        DO_DEFINE_TYPE_LENGTH(bool);
        DO_DEFINE_TYPE_LENGTH(size_t);
        DO_DEFINE_TYPE_LENGTH(CGFloat);
        DO_DEFINE_TYPE_LENGTH(CGSize);
        DO_DEFINE_TYPE_LENGTH(CGRect);
        DO_DEFINE_TYPE_LENGTH(CGPoint);
        DO_DEFINE_TYPE_LENGTH(CGVector);
        DO_DEFINE_TYPE_LENGTH(NSRange);
        DO_DEFINE_TYPE_LENGTH(NSInteger);
        DO_DEFINE_TYPE_LENGTH(NSUInteger);
        DO_DEFINE_TYPE_LENGTH(Class);
        DO_DEFINE_TYPE_LENGTH(SEL);
        [_typeLengthDict setObject:@(sizeof(SEL)) forKey:@"Selector"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"ptr"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"block"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"NSObject*"];
        [_typeLengthDict setObject:@(sizeof(NSObject *)) forKey:@"NSObject"];
    }
    return [_typeLengthDict[typeName] intValue];
}

NSString *DOTypeEncodeWithTypeName(NSString *typeName) {
    if (!typeName) return nil;
    static NSMutableDictionary *_typeEncodeDict;
    if (!_typeEncodeDict) {
        _typeEncodeDict = [[NSMutableDictionary alloc] init];
        #define DO_DEFINE_TYPE_ENCODE_CASE(_type) \
        [_typeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

        DO_DEFINE_TYPE_ENCODE_CASE(id);
        DO_DEFINE_TYPE_ENCODE_CASE(BOOL);
        DO_DEFINE_TYPE_ENCODE_CASE(int);
        DO_DEFINE_TYPE_ENCODE_CASE(void);
        DO_DEFINE_TYPE_ENCODE_CASE(char);
        DO_DEFINE_TYPE_ENCODE_CASE(short);
        DO_DEFINE_TYPE_ENCODE_CASE(unsigned short);
        DO_DEFINE_TYPE_ENCODE_CASE(unsigned int);
        DO_DEFINE_TYPE_ENCODE_CASE(long);
        DO_DEFINE_TYPE_ENCODE_CASE(unsigned long);
        DO_DEFINE_TYPE_ENCODE_CASE(long long);
        DO_DEFINE_TYPE_ENCODE_CASE(unsigned long long);
        DO_DEFINE_TYPE_ENCODE_CASE(float);
        DO_DEFINE_TYPE_ENCODE_CASE(double);
        DO_DEFINE_TYPE_ENCODE_CASE(bool);
        DO_DEFINE_TYPE_ENCODE_CASE(size_t);
        DO_DEFINE_TYPE_ENCODE_CASE(CGFloat);
        DO_DEFINE_TYPE_ENCODE_CASE(CGSize);
        DO_DEFINE_TYPE_ENCODE_CASE(CGRect);
        DO_DEFINE_TYPE_ENCODE_CASE(CGPoint);
        DO_DEFINE_TYPE_ENCODE_CASE(CGVector);
        DO_DEFINE_TYPE_ENCODE_CASE(NSRange);
        DO_DEFINE_TYPE_ENCODE_CASE(NSInteger);
        DO_DEFINE_TYPE_ENCODE_CASE(NSUInteger);
        DO_DEFINE_TYPE_ENCODE_CASE(Class);
        DO_DEFINE_TYPE_ENCODE_CASE(SEL);
        [_typeEncodeDict setObject:@"Selector" forKey:@"Selector"];
        [_typeEncodeDict setObject:@"^v" forKey:@"ptr"];
        [_typeEncodeDict setObject:@"@?" forKey:@"block"];
        [_typeEncodeDict setObject:@"^@" forKey:@"NSObject*"];
        [_typeEncodeDict setObject:@"@" forKey:@"NSObject"];
    }
    return _typeEncodeDict[typeName];
}

@interface DOFFIHelper ()

@property (nonatomic) NSMutableArray *allocations;

@end

@implementation DOFFIHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allocations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (ffi_type *)ffiTypeForStructEncode:(const char *)str
{
    NSUInteger size, align;
    long length;
    DOSizeAndAlignment(str, &size, &align, &length);
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

- (ffi_type *)ffiTypeForEncode:(const char *)str
{
    #define SINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            if(sizeof(type) == 1) \
                return &ffi_type_sint8; \
            else if(sizeof(type) == 2) \
                return &ffi_type_sint16; \
            else if(sizeof(type) == 4) \
                return &ffi_type_sint32; \
            else if(sizeof(type) == 8) \
                return &ffi_type_sint64; \
            else \
            { \
                NSLog(@"Unknown size for type %s", #type); \
                abort(); \
            } \
        } \
    } while(0)
    
    #define UINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            if(sizeof(type) == 1) \
                return &ffi_type_uint8; \
            else if(sizeof(type) == 2) \
                return &ffi_type_uint16; \
            else if(sizeof(type) == 4) \
                return &ffi_type_uint32; \
            else if(sizeof(type) == 8) \
                return &ffi_type_uint64; \
            else \
            { \
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
        if(str[0] == @encode(type)[0]) \
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

- (ffi_type **)argsWithEncodeString:(const char *)str getCount:(int *)outCount
{
    // 第一个是返回值，需要排除
    return [self typesWithEncodeString:str getCount:outCount startIndex:1];
}

- (ffi_type **)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start
{
    return [self typesWithEncodeString:str getCount:outCount startIndex:start nullAtEnd:NO];
}

- (ffi_type **)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start nullAtEnd:(BOOL)nullAtEnd
{
    int argCount = DOTypeCount(str) - start;
    ffi_type **argTypes = [self _allocate:(argCount + (nullAtEnd ? 1 : 0)) * sizeof(*argTypes)];
    
    int i = -start;
    while(str && *str)
    {
        const char *next = DOSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0 && i < argCount) {
            ffi_type *argType = [self ffiTypeForEncode:str];
            if (argType) {
                argTypes[i] = argType;
            }
            else {
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

- (void *)_allocate:(size_t)howmuch
{
    NSMutableData *data = [NSMutableData dataWithLength:howmuch];
    [self.allocations addObject:data];
    return data.mutableBytes;
}

@end
