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

static void DOFFIIMPClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata);

@interface DOMethodIMP ()
{
    ffi_cif _cif;
    ffi_closure *_closure;
    void *_methodIMP;
}

@property (nonatomic) DOFFIHelper *helper;
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
        _helper = [DOFFIHelper new];
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

static void DOFFIIMPClosureFunc(ffi_cif *cif, void *ret, void **args, void *userdata) {
    DOMethodIMP *methodIMP = (__bridge DOMethodIMP *)userdata;
    FlutterMethodChannel *channel = DartObjcPlugin.channel;
    
    if (methodIMP.thread == NSThread.currentThread && methodIMP.callback) {
        void(*callback)(void *target, SEL selector, void **args, void *ret, int argCount, const char **types) = methodIMP.callback;
        const char **types = native_types_encoding(methodIMP.typeEncoding, NULL, 0);
        // args: target, selector, realArgs...
        callback(*(void **)args[0], *(void **)args[1], args + 2, ret, (int)methodIMP.numberOfArguments - 2, types);
        free(types);
    }
    else {
        
    }
}
