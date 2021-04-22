//
//  DNBlockWrapper.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import "DNBlockWrapper.h"
#import "ffi.h"
#import "DNFFIHelper.h"
#import "DNInvocation.h"
#import <objc/runtime.h>
#import "NSThread+DartNative.h"
#import "DNPointerWrapper.h"
#import "native_runtime.h"
#import "DNError.h"
#import <stdatomic.h>

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

typedef void(*DNBlockCopyFunction)(void *, const void *);
typedef void(*DNBlockDisposeFunction)(const void *);
typedef void(*DNBlockInvokeFunction)(void *, ...);

struct _DNBlockDescriptor1 {
    uintptr_t reserved;
    uintptr_t size;
};

struct _DNBlockDescriptor2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    DNBlockCopyFunction copy;
    DNBlockDisposeFunction dispose;
};

struct _DNBlockDescriptor3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
};

struct _DNBlockDescriptor {
    struct _DNBlockDescriptor1 descriptor1;
    struct _DNBlockDescriptor2 descriptor2;
    struct _DNBlockDescriptor3 descriptor3;
};

struct _DNBlock {
    void *isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    DNBlockInvokeFunction invoke;
    struct _DNBlockDescriptor *descriptor;
    void *wrapper;
};

struct _DNBlockDescriptor3 * _dn_Block_descriptor_3(struct _DNBlock *aBlock) {
    if (!(aBlock->flags & BLOCK_HAS_SIGNATURE)) {
        return nil;
    }
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(struct _DNBlockDescriptor1);
    if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct _DNBlockDescriptor2);
    }
    return (struct _DNBlockDescriptor3 *)desc;
}

const char *DNBlockTypeEncodeString(id blockObj) {
    struct _DNBlock *block = (__bridge void *)blockObj;
    return _dn_Block_descriptor_3(block)->signature;
}

static void DNFFIBlockClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata);

static NSString *trim(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

void copy_helper(struct _DNBlock *dst, struct _DNBlock *src) {
    // do not copy anything is this funcion! just retain if need.
    CFRetain(dst->wrapper);
}

void dispose_helper(struct _DNBlock *src) {
    CFRelease(src->wrapper);
}

@interface DNBlockWrapper ()
{
    ffi_cif _cif;
    ffi_closure *_closure;
    struct _DNBlockDescriptor *_descriptor;
    void *_blockIMP;
}

@property (nonatomic, readwrite, weak) id block;
@property (nonatomic) intptr_t blockAddress;
@property (nonatomic) NSString *typeString;
@property (nonatomic) NSUInteger numberOfArguments;
@property (nonatomic, readwrite) const char **typeEncodings;
@property (nonatomic, getter=hasStret, readwrite) BOOL stret;
@property (nonatomic) NSMethodSignature *signature;
@property (nonatomic, readwrite) NativeBlockCallback callback;
@property (nonatomic) DNFFIHelper *helper;
@property (nonatomic) NSThread *thread;
@property (nonatomic, nullable) dispatch_queue_t queue;

@end

@implementation DNBlockWrapper

static atomic_uint_fast64_t _seq = 0;

- (instancetype)initWithTypeString:(char *)typeString
                          callback:(NativeBlockCallback)callback
                             error:(out NSError **)error {
    self = [super init];
    if (self) {
        _helper = [DNFFIHelper new];
        _typeString = [self _parseTypeNames:[NSString stringWithUTF8String:typeString]
                                      error:error];
        if (_typeString.length > 0) {
            _callback = callback;
            _thread = NSThread.currentThread;
            [self initBlockWithError:error];
            atomic_fetch_add(&_seq, 1);
            _sequence = _seq;
        }
    }
    return self;
}

- (void)dealloc {
    ffi_closure_free(_closure);
    free(_descriptor);
    free(_typeEncodings);
    NotifyDeallocToDart(_sequence);
}

- (void)initBlockWithError:(out NSError **)error {
    const char *typeString = self.typeString.UTF8String;
    int32_t flags = (BLOCK_HAS_COPY_DISPOSE | BLOCK_HAS_SIGNATURE);
    // Struct return value on x86(32&64) MUST be put into pointer.(On heap)
    if (typeString[0] == '{' && (TARGET_CPU_X86 || TARGET_CPU_X86_64)) {
        flags |= BLOCK_HAS_STRET;
    }
    // Check block encoding types valid.
    NSUInteger numberOfArguments = [self _prepCIF:&_cif
                                 withEncodeString:typeString
                                            flags:flags];
    if (numberOfArguments == -1) { // Unknown encode.
        DN_ERROR(DNCreateBlockError, @"Prepare ffi_cif failed.");
        return;
    }
    self.numberOfArguments = numberOfArguments;
    if (self.hasStret) {
        self.numberOfArguments--;
    }
    
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&_blockIMP);
    
    ffi_status status = ffi_prep_closure_loc(_closure, &_cif, DNFFIBlockClosureFunc, (__bridge void *)(self), _blockIMP);
    if (status != FFI_OK) {
        DN_ERROR(DNCreateBlockError, @"ffi_prep_closure returned %d", (int)status);
        return;
    }

    struct _DNBlockDescriptor descriptor = {
        0,
        sizeof(struct _DNBlock),
        (void (*)(void *dst, const void *src))copy_helper,
        (void (*)(const void *src))dispose_helper,
        typeString
    };
    
    _descriptor = malloc(sizeof(struct _DNBlockDescriptor));
    if (!_descriptor) {
        DN_ERROR(DNCreateBlockError, @"malloc _DNBlockDescriptor failed.")
        return;
    }
    memcpy(_descriptor, &descriptor, sizeof(struct _DNBlockDescriptor));

    struct _DNBlock simulateBlock = {
        &_NSConcreteStackBlock,
        flags,
        0,
        _blockIMP,
        _descriptor,
        (__bridge void*)self
    };
    _signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    _block = (__bridge id)Block_copy(&simulateBlock);
    SEL selector = NSSelectorFromString(@"autorelease");
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    _block = [_block performSelector:selector];
    #pragma clang diagnostic pop
}

- (intptr_t)blockAddress {
    if (!_blockAddress) {
        _blockAddress = (intptr_t)self.block;
    }
    return _blockAddress;
}

#pragma mark - Private Method

- (int)_prepCIF:(ffi_cif *)cif withEncodeString:(const char *)str flags:(int32_t)flags {
    int argCount;
    ffi_type **argTypes;
    ffi_type *returnType;
    
    if (flags & BLOCK_HAS_STRET) {
        argTypes = [self.helper typesWithEncodeString:str getCount:&argCount startIndex:0];
        if (!argTypes) { // Error!
            return -1;
        }
        argTypes[0] = &ffi_type_pointer;
        returnType = &ffi_type_void;
        self.stret = YES;
    } else {
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
                        error:(NSError **)error {
    NSMutableString *encodeStr = [[NSMutableString alloc] init];
    NSArray *typeArr = [typeNames componentsSeparatedByString:@","];
    if (!_typeEncodings) {
        _typeEncodings = malloc(sizeof(char *) * typeArr.count);
        if (_typeEncodings == NULL) {
            DN_ERROR(DNCreateTypeEncodingError, @"malloc for type encoding fail");
            return nil;
        }
    }
    NSString *retEncodeStr = @"";
    int currentLength = sizeof(void *); // Init length for block pointer
    for (NSInteger i = 0; i < typeArr.count; i++) {
        NSString *typeStr = trim([typeArr objectAtIndex:i]);
        NSString *encode = DNTypeEncodeWithTypeName(typeStr);
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
        int length = DNTypeLengthWithTypeName(typeStr);
        
        if (i == 0) {
            // Blocks are passed one implicit argument - the block, of type "@?".
            [encodeStr appendString:@"@?0"];
            retEncodeStr = encode;
        } else {
            [encodeStr appendString:encode];
            [encodeStr appendString:[NSString stringWithFormat:@"%d", currentLength]];
            currentLength += length;
        }
    }
    return [NSString stringWithFormat:@"%@%d%@", retEncodeStr, currentLength, encodeStr];
}

@end

static void DNHandleReturnValue(void *origRet, DNBlockWrapper *wrapper, DNInvocation *invocation) {
    void *ret = invocation.realRetValue;
    if (wrapper.hasStret) {
        // synchronize stret value from first argument. `origRet` is not the target.
        [invocation setReturnValue:*(void **)invocation.realArgs[0]];
        return;
    } else if ([wrapper.typeString hasPrefix:@"{"]) {
        DNPointerWrapper *pointerWrapper = *(DNPointerWrapper *__strong *)ret;
        if (pointerWrapper) {
            [invocation setReturnValue:pointerWrapper.pointer];
        }
    } else if ([wrapper.typeString hasPrefix:@"*"]) {
        DNPointerWrapper *pointerWrapper = *(DNPointerWrapper *__strong *)ret;
        if (pointerWrapper) {
            const char *origCString = (const char *)pointerWrapper.pointer;
            const char *temp = [NSString stringWithUTF8String:origCString].UTF8String;
            [invocation setReturnValue:&temp];
        }
    }
    [invocation getReturnValue:origRet];
}

static void DNFFIBlockClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata) {
    DNBlockWrapper *wrapper = (__bridge DNBlockWrapper *)userdata;
    
    if (!wrapper.callback) {
        return;
    }
    
    void *userRet = ret;
    void **userArgs = args;
    // handle struct return: should pass pointer to struct
    if (wrapper.hasStret) {
        // The first arg contains address of a pointer of returned struct.
        userRet = *((void **)args[0]);
        // Other args move backwards.
        userArgs = args + 1;
    }
    *(void **)userRet = NULL;
    __block int64_t retObjectAddr = 0;
    // Use (numberOfArguments - 1) exclude block itself.
    NSUInteger numberOfArguments = wrapper.numberOfArguments - 1;
    
    NSUInteger indexOffset = wrapper.hasStret ? 1 : 0;
    for (NSUInteger i = 0; i < wrapper.signature.numberOfArguments; i++) {
        const char *type = [wrapper.signature getArgumentTypeAtIndex:i];
        // Struct
        if (type[0] == '{') {
            NSUInteger size;
            DNSizeAndAlignment(type, &size, NULL, NULL);
            // Struct is copied on heap, it will be freed when dart side no longer owns it.
            void *temp = malloc(size);
            if (temp) {
                memcpy(temp, args[i + indexOffset], size);
            }
            // Dart side can handle null
            args[i + indexOffset] = temp;
        }
    }
    
    __block DNInvocation *invocation = [[DNInvocation alloc] initWithSignature:wrapper.signature
                                                                      hasStret:wrapper.hasStret];
    invocation.args = userArgs;
    invocation.retValue = userRet;
    invocation.realArgs = args;
    invocation.realRetValue = ret;
    
    int64_t retAddr = (int64_t)(invocation.realRetValue);
    
    if (wrapper.thread == NSThread.currentThread) {
        wrapper.callback(args,
                         ret,
                         (int)numberOfArguments,
                         wrapper.hasStret,
                         wrapper.sequence);
    } else {
        [invocation retainArguments];
        NotifyBlockInvokeToDart(invocation, wrapper, (int)numberOfArguments);
    }
    retObjectAddr = (int64_t)*(void **)retAddr;
    DNHandleReturnValue(ret, wrapper, invocation);
    [wrapper.thread dn_performBlock:^{
        NSThread.currentThread.threadDictionary[@(retObjectAddr)] = nil;
    }];
}


