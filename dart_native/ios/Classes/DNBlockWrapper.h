//
//  DNBlockWrapper.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import <Foundation/Foundation.h>
#import "DNMacro.h"
#import "dart_api_dl.h"

#ifndef DNBlockWrapper_h
#define DNBlockWrapper_h

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Block Layout

typedef void(*DNBlockCopyFunction)(void *, const void *);
typedef void(*DNBlockDisposeFunction)(const void *);
typedef void(*DNBlockInvokeFunction)(void *, ...);

typedef struct DNBlockDescriptor1 {
    uintptr_t reserved;
    uintptr_t size;
} DNBlockDescriptor1;

typedef struct DNBlockDescriptor2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    DNBlockCopyFunction copy;
    DNBlockDisposeFunction dispose;
} DNBlockDescriptor2;

typedef struct DNBlockDescriptor3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
} DNBlockDescriptor3;

typedef struct DNBlockDescriptor {
    DNBlockDescriptor1 descriptor1;
    DNBlockDescriptor2 descriptor2;
    DNBlockDescriptor3 descriptor3;
} DNBlockDescriptor;

typedef struct DNBlock {
    void *isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    DNBlockInvokeFunction invoke;
    DNBlockDescriptor *descriptor;
    void *wrapper;
} DNBlock;

#pragma mark - Block Wrapper

DN_EXTERN const char *DNBlockTypeEncodeString(id blockObj);

typedef void (*NativeBlockCallback)(void *_Nullable *_Null_unspecified args, void *ret, int numberOfArguments, BOOL stret, int64_t seq);

@interface DNBlockWrapper : NSObject

@property (nonatomic, readonly) const char *_Nonnull *_Nonnull typeEncodings;
@property (nonatomic, readonly) NativeBlockCallback callback;
@property (nonatomic, getter=hasStret, readonly) BOOL stret;
@property (nonatomic, readonly) int64_t sequence;
@property (nonatomic, readonly) Dart_Port dartPort;

- (intptr_t)blockAddress;

- (instancetype)initWithTypeString:(char *)typeString
                          callback:(NativeBlockCallback)callback
                          dartPort:(Dart_Port)dartPort
                             error:(out NSError **)error;

+ (void)invokeInterfaceBlock:(void *)block
                   arguments:(NSArray *)arguments
                      result:(void(^)(id result, NSError *error))resultCallback;
+ (BOOL)testNotifyDart:(int64_t)port;

@end

NS_ASSUME_NONNULL_END

#endif
