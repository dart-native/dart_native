//
//  DNBlockCreator.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/5/5.
//

#import "DNBlockCreator.h"
#import <objc/runtime.h>
#import <stdatomic.h>

#import "ffi.h"
#import "DNFFIHelper.h"
#import "DNInvocation.h"
#import "DNPointerWrapper.h"
#import "DNError.h"
#import "NSString+DartNative.h"
#import "DNObjCRuntime.h"
#import "DNDartBridge.h"

#if !__has_feature(objc_arc)
#error
#endif

#pragma mark - Block Helper

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

DNBlockDescriptor3 *dn_Block_descriptor_3(DNBlock *aBlock) {
    if (!(aBlock->flags & BLOCK_HAS_SIGNATURE)) {
        return nil;
    }
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(DNBlockDescriptor1);
    if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(DNBlockDescriptor2);
    }
    return (DNBlockDescriptor3 *)desc;
}

const char *DNBlockTypeEncodeString(id blockObj) {
    DNBlock *block = (__bridge void *)blockObj;
    return dn_Block_descriptor_3(block)->signature;
}

const char *_Nonnull *_Nonnull DNBlockTypeEncodings(id blockObj) {
    DNBlock *block = (__bridge void *)blockObj;
    DNBlockCreator *creator = (__bridge DNBlockCreator *)(block->creator);
    return creator.typeEncodings;
}

uint64_t DNBlockSequence(id blockObj) {
    DNBlock *block = (__bridge void *)blockObj;
    DNBlockCreator *creator = (__bridge DNBlockCreator *)(block->creator);
    return creator.sequence;
}

static void DNFFIBlockClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata);

static NSString *trim(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

void copy_helper(DNBlock *dst, DNBlock *src) {
    // do not copy anything is this funcion! just retain if need.
    CFRetain(dst->creator);
}

void dispose_helper(DNBlock *src) {
    CFRelease(src->creator);
}

#pragma mark - Block Wrapper

@interface DNBlockCreator () {
    ffi_cif _cif;
    ffi_closure *_closure;
    DNBlockDescriptor *_descriptor;
    void *_blockIMP;
}

@property (nonatomic) intptr_t blockAddress;
@property (nonatomic) NSString *typeString;
@property (nonatomic) NSUInteger numberOfArguments;
@property (nonatomic, readwrite) const char **typeEncodings;
@property (nonatomic, getter=hasStret, readwrite) BOOL stret;
@property (nonatomic, readwrite) NSMethodSignature *signature;
@property (nonatomic, readwrite) uint64_t sequence;
@property (nonatomic, readwrite) BlockFunctionPointer function;
@property (nonatomic, readwrite, getter=shouldReturnAsync) BOOL returnAsync;
@property (nonatomic) DNFFIHelper *helper;
@property (nonatomic) NSThread *thread;

@end

@implementation DNBlockCreator

static atomic_uint_fast64_t _seq = 0;

- (instancetype)initWithTypeString:(char *)typeString
                          function:(BlockFunctionPointer)function
                       returnAsync:(BOOL)returnAsync
                          dartPort:(Dart_Port)dartPort
                             error:(out NSError **)error {
    self = [super init];
    if (self) {
        _helper = [DNFFIHelper new];
        _typeString = [self _parseTypeNames:[NSString stringWithUTF8String:typeString]
                                      error:error];
        if (_typeString.length > 0) {
            _function = function;
            _returnAsync = returnAsync;
            _thread = NSThread.currentThread;
            _dartPort = dartPort;
        }
    }
    return self;
}

- (void)dealloc {
    ffi_closure_free(_closure);
    free(_descriptor);
    for (int i = 0; i < _numberOfArguments; i++) {
        if (*_typeEncodings[i] == '{') {
            free((void *)_typeEncodings[i]);
        }
    }
    free(_typeEncodings);
    NotifyDeallocToDart((intptr_t)_sequence, _dartPort);
}

- (id)blockWithError:(out NSError **)error {
    atomic_fetch_add(&_seq, 1);
    self.sequence = _seq;
    
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
        DN_ERROR(error, DNCreateBlockError, @"Prepare ffi_cif failed.");
        return nil;
    }
    self.numberOfArguments = numberOfArguments;
    if (self.hasStret) {
        self.numberOfArguments--;
    }
    
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&_blockIMP);
    
    ffi_status status = ffi_prep_closure_loc(_closure, &_cif, DNFFIBlockClosureFunc, (__bridge void *)(self), _blockIMP);
    if (status != FFI_OK) {
        DN_ERROR(error, DNCreateBlockError, @"ffi_prep_closure returned %d", (int)status);
        return nil;
    }

    DNBlockDescriptor descriptor = {
        0,
        sizeof(DNBlock),
        (void (*)(void *dst, const void *src))copy_helper,
        (void (*)(const void *src))dispose_helper,
        typeString
    };
    
    _descriptor = malloc(sizeof(DNBlockDescriptor));
    if (!_descriptor) {
        DN_ERROR(error, DNCreateBlockError, @"malloc _DNBlockDescriptor failed.")
        return nil;
    }
    memcpy(_descriptor, &descriptor, sizeof(DNBlockDescriptor));

    DNBlock simulateBlock = {
        &_NSConcreteStackBlock,
        flags,
        0,
        _blockIMP,
        _descriptor,
        (__bridge void *)self
    };
    _signature = [NSMethodSignature signatureWithObjCTypes:typeString];
    id block = (__bridge id)Block_copy(&simulateBlock);
    return block;
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
            DN_ERROR(error, DNCreateTypeEncodingError, @"malloc for type encoding fail");
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
        
        self.typeEncodings[i] = native_type_encoding(encode.UTF8String);
        
        int length = DNTypeLengthWithTypeName(typeStr);
        
        if (i == 0) {
            // Blocks are passed one implicit argument - the block, of type "@?".
            [encodeStr appendString:@"@?0"];
            retEncodeStr = encode;
            if ([typeStr isEqualToString:@"String"]) {
                self.typeEncodings[i] = native_type_string;
            }
        } else {
            [encodeStr appendString:encode];
            [encodeStr appendString:[NSString stringWithFormat:@"%d", currentLength]];
            currentLength += length;
        }
    }
    return [NSString stringWithFormat:@"%@%d%@", retEncodeStr, currentLength, encodeStr];
}

@end

static void DNHandleReturnValue(void *origRet, DNBlockCreator *creator, DNInvocation *invocation) {
    void *ret = invocation.realRetValue;
    if (creator.hasStret) {
        // synchronize stret value from first argument. `origRet` is not the target.
        [invocation setReturnValue:*(void **)invocation.realArgs[0]];
        return;
    } else if (creator.typeEncodings[0] == native_type_string) {
        // type is native_type_object but result is a string
        NSString *string = [NSString dn_stringWithUTF16String:*(const unichar **)ret];
        if (string) {
            native_retain_object(string);
            [invocation setReturnValue:&string];
        }
    } else if ([creator.typeString hasPrefix:@"{"]) {
        DNPointerWrapper *pointerWrapper = *(DNPointerWrapper *__strong *)ret;
        if (pointerWrapper) {
            [invocation setReturnValue:pointerWrapper.pointer];
        }
    } else if ([creator.typeString hasPrefix:@"*"]) {
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
    DNBlockCreator *creator = (__bridge DNBlockCreator *)userdata;
    
    if (!creator.function) {
        return;
    }
    
    void *userRet = ret;
    void **userArgs = args;
    // handle struct return: should pass pointer to struct
    if (creator.hasStret) {
        // The first arg contains address of a pointer of returned struct.
        userRet = *((void **)args[0]);
        // Other args move backwards.
        userArgs = args + 1;
    }
    *(void **)userRet = NULL;
    __block int64_t retObjectAddr = 0;
    // Use (numberOfArguments - 1) exclude block itself.
    NSUInteger numberOfArguments = creator.numberOfArguments - 1;
    
    NSUInteger indexOffset = creator.hasStret ? 1 : 0;
    for (NSUInteger i = 0; i < creator.signature.numberOfArguments; i++) {
        const char *type = [creator.signature getArgumentTypeAtIndex:i];
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
    
    __block DNInvocation *invocation = [[DNInvocation alloc] initWithSignature:creator.signature
                                                                      hasStret:creator.hasStret];
    invocation.args = userArgs;
    invocation.retValue = userRet;
    invocation.realArgs = args;
    invocation.realRetValue = ret;
    
    int64_t retAddr = (int64_t)(invocation.realRetValue);
    
    if (creator.thread == NSThread.currentThread) {
        creator.function(args,
                         ret,
                         (int)numberOfArguments,
                         creator.hasStret,
                         creator.sequence);
    } else {
        [invocation retainArguments];
        NotifyBlockInvokeToDart(invocation, creator, (int)numberOfArguments);
    }
    retObjectAddr = (int64_t)*(void **)retAddr;
    DNHandleReturnValue(ret, creator, invocation);
    const char *type = creator.typeEncodings[0];
    if (type == native_type_object || type == native_type_block || type == native_type_string) {
        native_autorelease_object((__bridge id)*(void **)retAddr);
    }
}


