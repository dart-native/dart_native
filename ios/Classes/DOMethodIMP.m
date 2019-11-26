//
//  DOMethodIMP.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import "DOMethodIMP.h"
#import "DOFFIHelper.h"
#import "DartObjcPlugin.h"
#import "native_runtime.h"
#import "DOInvocation.h"
#import "NSThread+DartObjC.h"

static void DOFFIIMPClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata);

@interface DOMethodIMP ()
{
    ffi_cif _cif;
    ffi_closure *_closure;
    void *_methodIMP;
}

@property (nonatomic) NSUInteger numberOfArguments;
@property (nonatomic) const char *typeEncoding;
@property (nonatomic) NSThread *thread;
@property (nonatomic) void *callback;

@end

@implementation DOMethodIMP

- (instancetype)initWithTypeEncoding:(const char *)typeEncoding callback:(void *)callback
{
    self = [super init];
    if (self) {
        _typeEncoding = typeEncoding;
        _callback = callback;
        _thread = NSThread.currentThread;
    }
    return self;
}

- (void)dealloc
{
    ffi_closure_free(_closure);
}

- (IMP)imp
{
    if (!_methodIMP) {
        NSUInteger numberOfArguments = [self _prepCIF:&_cif withEncodeString:self.typeEncoding];
        if (numberOfArguments == -1) { // Unknown encode.
            return nil;
        }
        self.numberOfArguments = numberOfArguments;
        
        _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&_methodIMP);
        ffi_status status = ffi_prep_closure_loc(_closure, &_cif, DOFFIIMPClosureFunc, (__bridge void *)(self), _methodIMP);
        if (status != FFI_OK) {
            NSLog(@"ffi_prep_closure returned %d", (int)status);
            abort();
        }
    }
    return _methodIMP;
}

- (int)_prepCIF:(ffi_cif *)cif withEncodeString:(const char *)str
{
    int argCount;
    ffi_type **argTypes;
    ffi_type *returnType;
    
    DOFFIHelper *helper = [DOFFIHelper new];
    // TODO: handle struct return on x86
    argTypes = [helper argsWithEncodeString:str getCount:&argCount];
    if (!argTypes) { // Error!
        return -1;
    }
    returnType = [helper ffiTypeForEncode:str];
    
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

static void DOFFIIMPClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata) {
    DOMethodIMP *methodIMP = (__bridge DOMethodIMP *)userdata;
    FlutterMethodChannel *channel = DartObjcPlugin.channel;
    
    void *userRet = ret;
    void **userArgs = args;
//    TODO: handle stret on x86
//    if (hasStret) {
//        // The first arg contains address of a pointer of returned struct.
//        userRet = *((void **)args[0]);
//        // Other args move backwards.
//        userArgs = args + 1;
//    }
    *(void **)userRet = NULL;
    
    int argCount = (int)methodIMP.numberOfArguments - 2;
    const char **types = native_types_encoding(methodIMP.typeEncoding, NULL, 0);
    int64_t retObjectAddr = 0;
    if (methodIMP.thread == NSThread.currentThread && methodIMP.callback) {
        void(*callback)(void *target, SEL selector, void **args, void *ret, int argCount, const char **types) = methodIMP.callback;
        // args: target, selector, realArgs...
        callback(*(void **)args[0], *(void **)args[1], args + 2, ret, argCount, types);
        free(types);
        retObjectAddr = (int64_t)*(void **)ret;
    }
    else {
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:methodIMP.typeEncoding];
        __block DOInvocation *invocation = [[DOInvocation alloc] initWithSignature:signature hasStret:NO];
        invocation.args = userArgs;
        invocation.retValue = userRet;
        invocation.realArgs = args;
        invocation.realRetValue = ret;
        
        int64_t targetAddr = (int64_t)(*(void **)invocation.args[0]);
        int64_t selectorAddr = (int64_t)(*(void **)invocation.args[1]);
        int64_t argsAddr = (int64_t)(invocation.args + 2);
        int64_t retAddr = (int64_t)(invocation.retValue);
        int64_t typesAddr = (int64_t)types;
        
        [invocation retainArguments];
        
        dispatch_semaphore_t sema;
        if (!NSThread.isMainThread) {
            sema = dispatch_semaphore_create(0);
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            [channel invokeMethod:@"method_delegate" arguments:@[@(targetAddr), @(selectorAddr), @(argsAddr), @(retAddr), @(argCount), @(typesAddr)] result:^(id  _Nullable result) {
                invocation = nil;
                if (sema) {
                    dispatch_semaphore_signal(sema);
                }
            }];
        });
        if (sema) {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        retObjectAddr = (int64_t)*(void **)retAddr;
    }
    [methodIMP.thread do_performBlock:^{
        NSThread.currentThread.threadDictionary[@(retObjectAddr)] = nil;
    }];
}
