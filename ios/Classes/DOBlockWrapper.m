//
//  BlockCreator.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import "DOBlockWrapper.h"
#import "ffi.h"
#import <Flutter/Flutter.h>
#import "DartObjcPlugin.h"

#if !__has_feature(objc_arc)
#error
#endif

#pragma mark - Block Layout

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

typedef void(*BHBlockCopyFunction)(void *, const void *);
typedef void(*BHBlockDisposeFunction)(const void *);
typedef void(*BHBlockInvokeFunction)(void *, ...);

struct _DOBlockDescriptor1
{
    uintptr_t reserved;
    uintptr_t size;
};

struct _DOBlockDescriptor2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    BHBlockCopyFunction copy;
    BHBlockDisposeFunction dispose;
};

struct _DOBlockDescriptor3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
};

struct _DOBlockDescriptor {
    struct _DOBlockDescriptor1 descriptor1;
    struct _DOBlockDescriptor2 descriptor2;
    struct _DOBlockDescriptor3 descriptor3;
};

struct _DOBlock
{
    void *isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    BHBlockInvokeFunction invoke;
    struct _DOBlockDescriptor *descriptor;
    void *wrapper;
};

static const char *BHSizeAndAlignment(const char *str, NSUInteger *sizep, NSUInteger *alignp, long *lenp)
{
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

static int BHTypeCount(const char *str)
{
    int typeCount = 0;
    while(str && *str)
    {
        str = BHSizeAndAlignment(str, NULL, NULL, NULL);
        typeCount++;
    }
    return typeCount;
}

static int typeLengthWithTypeName(NSString *typeName)
{
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
        DO_DEFINE_TYPE_LENGTH(void*);
        DO_DEFINE_TYPE_LENGTH(void *);
        DO_DEFINE_TYPE_LENGTH(id *);
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"block"];
        [_typeLengthDict setObject:@(sizeof(void *)) forKey:@"id*"];
        [_typeLengthDict setObject:@(sizeof(NSObject *)) forKey:@"NSObject"];
    }
    return [_typeLengthDict[typeName] intValue];
}

static NSString *typeEncodeWithTypeName(NSString *typeName)
{
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
        DO_DEFINE_TYPE_ENCODE_CASE(void*);
        DO_DEFINE_TYPE_ENCODE_CASE(void *);
        [_typeEncodeDict setObject:@"@?" forKey:@"block"];
        [_typeEncodeDict setObject:@"^@" forKey:@"id*"];
        [_typeEncodeDict setObject:@"@" forKey:@"NSObject"];
    }
    return _typeEncodeDict[typeName];
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static NSString *parseTypeNames(NSString *typeNames)
{
    NSMutableString *encodeStr = [[NSMutableString alloc] init];
    NSArray *typeArr = [typeNames componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < typeArr.count; i++) {
        NSString *typeStr = trim([typeArr objectAtIndex:i]);
        NSString *encode = typeEncodeWithTypeName(typeStr);
        if (!encode) {
            NSString *argClassName = trim([typeStr stringByReplacingOccurrencesOfString:@"*" withString:@""]);
            if (NSClassFromString(argClassName) != NULL) {
                encode = @"@";
            } else {
                NSCAssert(NO, @"unreconized type %@", typeStr);
                return nil;
            }
        }
        [encodeStr appendString:encode];
        int length = typeLengthWithTypeName(typeStr);
        // TODO: fix length issue
        [encodeStr appendString:[NSString stringWithFormat:@"%d", length]];
        
        if (i == 0) {
            // Blocks are passed one implicit argument - the block, of type "@?".
            [encodeStr appendString:@"@?0"];
        }
    }
    return encodeStr;
}

void copy_helper(struct _DOBlock *dst, struct _DOBlock *src)
{
    // do not copy anything is this funcion! just retain if need.
    CFRetain(dst->wrapper);
}

void dispose_helper(struct _DOBlock *src)
{
    CFRelease(src->wrapper);
}

@interface DOBlockWrapper ()
{
    ffi_cif _cif;
    ffi_closure *_closure;
    struct _DOBlockDescriptor *_descriptor;
}

@property (nonatomic, readwrite) id block;
@property (nonatomic) NSMutableArray *allocations;
@property (nonatomic) NSString *typeString;
@property (nonatomic) NSUInteger numberOfArguments;

@end

void BHFFIClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata)
{
    DOBlockWrapper *blockWrapper = (__bridge DOBlockWrapper*)userdata;
    FlutterMethodChannel *channel = DartObjcPlugin.channel;
    // TODO: call channel with args and invoke function address
    int64_t blockAddr = (int64_t)blockWrapper.block;
    int64_t argsAddr = (int64_t)args;
    [channel invokeMethod:@"block_invoke" arguments:@[@(blockAddr), @(argsAddr), @(blockWrapper.numberOfArguments)] result:^(id  _Nullable result) {
        NSLog(@"block_invoke result:%@", result);
    }];
}


@implementation DOBlockWrapper

- (instancetype)initWithTypeString:(char *)typeString
{
    self = [super init];
    if (self) {
        _allocations = [[NSMutableArray alloc] init];
        _typeString = parseTypeNames([NSString stringWithUTF8String:typeString]);
    }
    return self;
}

- (void)dealloc
{
    ffi_closure_free(_closure);
    free(_descriptor);
    return;
}

- (id)block
{
    if (_block) {
        return _block;
    }
    const char *typeString = self.typeString.UTF8String;
    // Check block encoding types valid.
    NSUInteger numberOfArguments = [self _prepCIF:&_cif withEncodeString:typeString];
    if (numberOfArguments == -1) { // Unknown encode.
        return nil;
    }
    self.numberOfArguments = numberOfArguments;
    void *blockImp = NULL;
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&blockImp);
    
    ffi_status status = ffi_prep_closure_loc(_closure, &_cif, BHFFIClosureFunc, (__bridge void *)(self), blockImp);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure returned %d", (int)status);
        abort();
    }

    struct _DOBlockDescriptor descriptor = {
        0,
        sizeof(struct _DOBlock),
        (void (*)(void *dst, const void *src))copy_helper,
        (void (*)(const void *src))dispose_helper,
        typeString
    };
    
    _descriptor = malloc(sizeof(struct _DOBlockDescriptor));
    memcpy(_descriptor, &descriptor, sizeof(struct _DOBlockDescriptor));

    struct _DOBlock simulateBlock = {
        &_NSConcreteStackBlock,
        (BLOCK_HAS_COPY_DISPOSE | BLOCK_HAS_SIGNATURE),
        0,
        blockImp,
        _descriptor,
        (__bridge void*)self
    };

    _block = (__bridge id)Block_copy(&simulateBlock);
    return _block;
}

#pragma mark - Private Method

- (void *)_allocate:(size_t)howmuch
{
    NSMutableData *data = [NSMutableData dataWithLength:howmuch];
    [self.allocations addObject:data];
    return data.mutableBytes;
}

- (ffi_type *)_ffiTypeForStructEncode:(const char *)str
{
    NSUInteger size, align;
    long length;
    BHSizeAndAlignment(str, &size, &align, &length);
    ffi_type *structType = [self _allocate:sizeof(*structType)];
    structType->type = FFI_TYPE_STRUCT;
    
    const char *temp = [[[NSString stringWithUTF8String:str] substringWithRange:NSMakeRange(0, length)] UTF8String];
    
    // cut "struct="
    while (temp && *temp && *temp != '=') {
        temp++;
    }
    int elementCount = 0;
    ffi_type **elements = [self _typesWithEncodeString:temp + 1 getCount:&elementCount startIndex:0 nullAtEnd:YES];
    if (!elements) {
        return nil;
    }
    structType->elements = elements;
    return structType;
}

- (ffi_type *)_ffiTypeForEncode:(const char *)str
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
            return [self _ffiTypeForEncode:str + 1];
    }
    
    // Struct Type Encodings
    if (*str == '{') {
        ffi_type *structType = [self _ffiTypeForStructEncode:str];
        return structType;
    }
    
    NSLog(@"Unknown encode string %s", str);
    return nil;
}

- (ffi_type **)_argsWithEncodeString:(const char *)str getCount:(int *)outCount
{
    // 第一个是返回值，需要排除
    return [self _typesWithEncodeString:str getCount:outCount startIndex:1];
}

- (ffi_type **)_typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start
{
    return [self _typesWithEncodeString:str getCount:outCount startIndex:start nullAtEnd:NO];
}

- (ffi_type **)_typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start nullAtEnd:(BOOL)nullAtEnd
{
    int argCount = BHTypeCount(str) - start;
    ffi_type **argTypes = [self _allocate:(argCount + (nullAtEnd ? 1 : 0)) * sizeof(*argTypes)];
    
    int i = -start;
    while(str && *str)
    {
        const char *next = BHSizeAndAlignment(str, NULL, NULL, NULL);
        if (i >= 0 && i < argCount) {
            ffi_type *argType = [self _ffiTypeForEncode:str];
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

- (int)_prepCIF:(ffi_cif *)cif withEncodeString:(const char *)str
{
    int argCount;
    ffi_type **argTypes;
    ffi_type *returnType;
//    TODO: handle x86 stret
//    struct _BHBlock *bh_block = (__bridge void *)self.block;
//    if ((bh_block->flags & BLOCK_HAS_STRET)) {
//        argTypes = [self _typesWithEncodeString:str getCount:&argCount startIndex:0];
//        if (!argTypes) { // Error!
//            return -1;
//        }
//        argTypes[0] = &ffi_type_pointer;
//        returnType = &ffi_type_void;
//        self.stret = YES;
//    }
//    else {
        argTypes = [self _argsWithEncodeString:str getCount:&argCount];
        if (!argTypes) { // Error!
            return -1;
        }
        returnType = [self _ffiTypeForEncode:str];
//    }
    if (!returnType) { // Error!
        return -1;
    }
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, argCount, returnType, argTypes);
    if (status != FFI_OK) {
        NSLog(@"Got result %ld from ffi_prep_cif", (long)status);
        abort();
    }
    return argCount;
}

@end

