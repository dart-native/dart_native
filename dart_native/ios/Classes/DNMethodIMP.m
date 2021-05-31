//
//  DNMethodIMP.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import "DNMethodIMP.h"
#import "DNFFIHelper.h"
#import "native_runtime.h"
#import "DNInvocation.h"
#import "NSThread+DartNative.h"
#import "DNPointerWrapper.h"
#import "DNError.h"

#if !__has_feature(objc_arc)
#error
#endif

static void DNFFIIMPClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata);

@interface DNMethodIMP ()
{
    ffi_cif _cif;
    ffi_closure *_closure;
    void *_methodIMP;
}

@property (nonatomic) NSUInteger numberOfArguments;
@property (nonatomic) char *typeEncoding;
@property (nonatomic) NSThread *thread;
@property (nonatomic, readwrite) NativeMethodCallback callback;
@property (nonatomic) DNFFIHelper *helper;
@property (nonatomic) NSMethodSignature *signature;
@property (nonatomic, getter=hasStret, readwrite) BOOL stret;

@end

@implementation DNMethodIMP

- (instancetype)initWithTypeEncoding:(const char *)typeEncoding
                            callback:(NativeMethodCallback)callback
                            dartPort:(Dart_Port)dartPort
                               error:(out NSError **)error {
    self = [super init];
    if (self) {
        _helper = [DNFFIHelper new];
        size_t length = strlen(typeEncoding) + 1;
        size_t size = sizeof(char) * length;
        _typeEncoding = malloc(size);
        if (_typeEncoding == NULL) {
            DN_ERROR(DNCreateTypeEncodingError, @"malloc for type encoding fail: %s", typeEncoding);
            return self;
        }
        strlcpy(_typeEncoding, typeEncoding, length);
        _callback = callback;
        _thread = NSThread.currentThread;
        _dartPort = dartPort;
        _signature = [NSMethodSignature signatureWithObjCTypes:_typeEncoding];
    }
    return self;
}

- (void)dealloc {
    free(_typeEncoding);
    ffi_closure_free(_closure);
}

- (IMP)imp {
    if (!_methodIMP) {
        NSUInteger numberOfArguments = [self _prepCIF:&_cif withEncodeString:self.typeEncoding];
        if (numberOfArguments == -1) { // Unknown encode.
            return nil;
        }
        self.numberOfArguments = numberOfArguments;
        
        _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&_methodIMP);
        ffi_status status = ffi_prep_closure_loc(_closure, &_cif, DNFFIIMPClosureFunc, (__bridge void *)(self), _methodIMP);
        if (status != FFI_OK) {
            NSLog(@"ffi_prep_closure returned %d", (int)status);
            abort();
        }
    }
    return _methodIMP;
}

- (int)_prepCIF:(ffi_cif *)cif withEncodeString:(const char *)str {
    int argCount;
    ffi_type **argTypes;
    ffi_type *returnType;
    
    // TODO: handle struct return on x86
    argTypes = [self.helper argsWithEncodeString:str getCount:&argCount];
    if (!argTypes) { // Error!
        return -1;
    }
    returnType = [self.helper ffiTypeForEncode:str];
    
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

static void DNHandleReturnValue(void *origRet, DNMethodIMP *methodIMP, DNInvocation *invocation) {
    void *ret = invocation.realRetValue;
    if (methodIMP.hasStret) {
        // synchronize stret value from first argument. `origRet` is not the target.
        [invocation setReturnValue:*(void **)invocation.realArgs[0]];
        return;
    } else if (methodIMP.typeEncoding[0] == '{') {
        DNPointerWrapper *pointerWrapper = *(DNPointerWrapper *__strong *)ret;
        if (pointerWrapper) {
            [invocation setReturnValue:pointerWrapper.pointer];
        }
    } else if (methodIMP.typeEncoding[0] == '*') {
        DNPointerWrapper *pointerWrapper = *(DNPointerWrapper *__strong *)ret;
        if (pointerWrapper) {
            const char *origCString = (const char *)pointerWrapper.pointer;
            const char *temp = [NSString stringWithUTF8String:origCString].UTF8String;
            [invocation setReturnValue:&temp];
        }
    }
    [invocation getReturnValue:origRet];
}

static void DNFFIIMPClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata) {
    DNMethodIMP *methodIMP = (__bridge DNMethodIMP *)userdata;
    if (!methodIMP.callback) {
        return;
    }
    
    void *userRet = ret;
    void **userArgs = args;
    // handle struct return: should pass pointer to struct
    if (methodIMP.hasStret) {
        // The first arg contains address of a pointer of returned struct.
        userRet = *((void **)args[0]);
        // Other args move backwards.
        userArgs = args + 1;
    }
    *(void **)userRet = NULL;
    __block int64_t retObjectAddr = 0;
    // Use (numberOfArguments - 2) exclude itself and _cmd.
    int numberOfArguments = (int)methodIMP.numberOfArguments - 2;
    
    NSUInteger indexOffset = methodIMP.hasStret ? 1 : 0;
    for (NSUInteger i = 0; i < methodIMP.signature.numberOfArguments; i++) {
        const char *type = [methodIMP.signature getArgumentTypeAtIndex:i];
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
    int typesCount = 0;
    const char **types = native_types_encoding(methodIMP.typeEncoding, &typesCount, 0);
    if (!types) {
        return;
    }
    
    DNInvocation *invocation = [[DNInvocation alloc] initWithSignature:methodIMP.signature
                                                              hasStret:methodIMP.hasStret];
    invocation.args = userArgs;
    invocation.retValue = userRet;
    invocation.realArgs = args;
    invocation.realRetValue = ret;
    
    int64_t retAddr = (int64_t)(invocation.realRetValue);
    
    if (methodIMP.thread == NSThread.currentThread) {
        void(*callback)(void **args, void *ret, int numberOfArguments, const char **types, BOOL stret) = methodIMP.callback;
        // args: target, selector, realArgs...
        callback(args, ret, numberOfArguments, types, methodIMP.hasStret);
    } else {
        [invocation retainArguments];
        NotifyMethodPerformToDart(invocation, methodIMP, numberOfArguments, types);
    }
    for (int i = 0; i < typesCount; i++) {
        if (*types[i] == '{') {
            free((void *)types[i]);
        }
    }
    free(types);
    retObjectAddr = (int64_t)*(void **)retAddr;
    DNHandleReturnValue(ret, methodIMP, invocation);
    [methodIMP.thread dn_performBlock:^{
        NSThread.currentThread.threadDictionary[@(retObjectAddr)] = nil;
    }];
}

