//
//  DOBlockWrapper.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import "DOBlockWrapper.h"
#import "ffi.h"
#import <Flutter/Flutter.h>
#import "DartObjcPlugin.h"
#import "DOFFIHelper.h"
#import "DOInvocation.h"

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

typedef void(*DOBlockCopyFunction)(void *, const void *);
typedef void(*DOBlockDisposeFunction)(const void *);
typedef void(*DOBlockInvokeFunction)(void *, ...);

struct _DOBlockDescriptor1
{
    uintptr_t reserved;
    uintptr_t size;
};

struct _DOBlockDescriptor2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    DOBlockCopyFunction copy;
    DOBlockDisposeFunction dispose;
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
    DOBlockInvokeFunction invoke;
    struct _DOBlockDescriptor *descriptor;
    void *wrapper;
};

struct _DOBlockDescriptor3 * _do_Block_descriptor_3(struct _DOBlock *aBlock)
{
    if (! (aBlock->flags & BLOCK_HAS_SIGNATURE)) return nil;
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(struct _DOBlockDescriptor1);
    if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct _DOBlockDescriptor2);
    }
    return (struct _DOBlockDescriptor3 *)desc;
}

const char *DOBlockTypeEncodeString(id blockObj)
{
    struct _DOBlock *block = (__bridge void *)blockObj;
    return _do_Block_descriptor_3(block)->signature;
}

static void DOFFIBlockClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata);

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    void *_blockIMP;
    void *_block;
}

@property (nonatomic) DOFFIHelper *helper;
@property (nonatomic) NSString *typeString;
@property (nonatomic) NSUInteger numberOfArguments;
@property (nonatomic) const char **typeEncodings;
@property (nonatomic, getter=hasStret) BOOL stret;
@property (nonatomic) NSMethodSignature *signature;
@property (nonatomic) void *callback;
@property (nonatomic) NSThread *thread;

- (void)invokeWithArgs:(void **)args retValue:(void *)retValue;

@end

@implementation DOBlockWrapper

- (instancetype)initWithTypeString:(char *)typeString callback:(void *)callback
{
    self = [super init];
    if (self) {
        _helper = [DOFFIHelper new];
        _typeString = [self _parseTypeNames:[NSString stringWithUTF8String:typeString]];
        _callback = callback;
        _thread = NSThread.currentThread;
    }
    return self;
}

- (void)dealloc
{
    ffi_closure_free(_closure);
    free(_descriptor);
    free(_typeEncodings);
}

- (id)block
{
    if (_block) {
        return (__bridge id _Nonnull)(_block);
    }
    const char *typeString = self.typeString.UTF8String;
    int32_t flags = (BLOCK_HAS_COPY_DISPOSE | BLOCK_HAS_SIGNATURE);
    // Check block encoding types valid.
    NSUInteger numberOfArguments = [self _prepCIF:&_cif withEncodeString:typeString flags:flags];
    if (numberOfArguments == -1) { // Unknown encode.
        return nil;
    }
    self.numberOfArguments = numberOfArguments;
    
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&_blockIMP);
    
    ffi_status status = ffi_prep_closure_loc(_closure, &_cif, DOFFIBlockClosureFunc, (__bridge void *)(self), _blockIMP);
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
//    TODO: handle x86 stret
    struct _DOBlock simulateBlock = {
        &_NSConcreteStackBlock,
        flags,
        0,
        _blockIMP,
        _descriptor,
        (__bridge void*)self
    };
    _signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    _block = Block_copy(&simulateBlock);
    return (__bridge id _Nonnull)(_block);
}

- (void)invokeWithArgs:(void **)args retValue:(void *)retValue
{
    ffi_call(&_cif, _blockIMP, retValue, args);
}

- (int)_prepCIF:(ffi_cif *)cif withEncodeString:(const char *)str flags:(int32_t)flags
{
    int argCount;
    ffi_type **argTypes;
    ffi_type *returnType;
    if ((flags & BLOCK_HAS_STRET)) {
        argTypes = [self.helper typesWithEncodeString:str getCount:&argCount startIndex:0];
        if (!argTypes) { // Error!
            return -1;
        }
        argTypes[0] = &ffi_type_pointer;
        returnType = &ffi_type_void;
        self.stret = YES;
    }
    else {
        argTypes = [self.helper argsWithEncodeString:str getCount:&argCount];
        if (!argTypes) { // Error!
            return -1;
        }
        returnType = [self.helper ffiTypeForEncode:str];
    }
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

- (NSString *)_parseTypeNames:(NSString *)typeNames
{
    NSMutableString *encodeStr = [[NSMutableString alloc] init];
    NSArray *typeArr = [typeNames componentsSeparatedByString:@","];
    if (!_typeEncodings) {
        _typeEncodings = malloc(sizeof(char *) * typeArr.count);
    }
    NSString *retEncodeStr = @"";
    int currentLength = sizeof(void *); // Init length for block pointer
    for (NSInteger i = 0; i < typeArr.count; i++) {
        NSString *typeStr = trim([typeArr objectAtIndex:i]);
        NSString *encode = DOTypeEncodeWithTypeName(typeStr);
        if (!encode) {
            NSString *argClassName = trim([typeStr stringByReplacingOccurrencesOfString:@"*" withString:@""]);
            if (NSClassFromString(argClassName) != NULL) {
                encode = @"@";
            } else {
                NSCAssert(NO, @"unreconized type %@", typeStr);
                return nil;
            }
        }
        
        *(self.typeEncodings + i) = encode.UTF8String;
        int length = DOTypeLengthWithTypeName(typeStr);
        
        if (i == 0) {
            // Blocks are passed one implicit argument - the block, of type "@?".
            [encodeStr appendString:@"@?0"];
            retEncodeStr = encode;
        }
        else {
            [encodeStr appendString:encode];
            [encodeStr appendString:[NSString stringWithFormat:@"%d", currentLength]];
            currentLength += length;
        }
    }
    return [NSString stringWithFormat:@"%@%d%@", retEncodeStr, currentLength, encodeStr];
}

@end

static void DOFFIBlockClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata) {
    @autoreleasepool {
        DOBlockWrapper *wrapper = (__bridge DOBlockWrapper *)userdata;
        FlutterMethodChannel *channel = DartObjcPlugin.channel;
        int64_t blockAddr = (int64_t)wrapper.block;
        void *userRet = ret;
        void **userArgs = args;
        if (wrapper.hasStret) {
            // The first arg contains address of a pointer of returned struct.
            userRet = *((void **)args[0]);
            // Other args move backwards.
            userArgs = args + 1;
        }
        *(void **)userRet = NULL;
        
        if (wrapper.thread == NSThread.currentThread && wrapper.callback) {
            void(*callback)(void *block, void **args, void *ret, int argCount) = wrapper.callback;
            callback((__bridge void *)(wrapper.block), args + 1, ret, (int)wrapper.numberOfArguments - 1);
        }
        else {
            __block DOInvocation *invocation = [[DOInvocation alloc] initWithSignature:wrapper.signature hasStret:wrapper.hasStret];
            invocation.args = userArgs;
            invocation.retValue = userRet;
            invocation.realArgs = args;
            invocation.realRetValue = ret;
            [invocation retainArguments];
            
            // Use (numberOfArguments - 1) exclude block itself.
            int64_t argsAddr = (int64_t)(invocation.args + 1);
            dispatch_semaphore_t sema;
            if (!NSThread.isMainThread) {
                sema = dispatch_semaphore_create(0);
            }
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                [channel invokeMethod:@"block_invoke" arguments:@[@(blockAddr), @(argsAddr), @(wrapper.numberOfArguments - 1)] result:^(id  _Nullable result) {
                    const char *retType = wrapper.typeEncodings[0];
                    if (result) {
                        DOStoreValueToPointer(result, ret, retType);
                    }
                    invocation = nil;
                    if (sema) {
                        dispatch_semaphore_signal(sema);
                    }
                }];
            });
            if (sema) {
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }
        }
    }
}


