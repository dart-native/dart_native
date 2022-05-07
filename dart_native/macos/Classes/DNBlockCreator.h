//
//  DNBlockCreator.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/5/5.
//

#import <Foundation/Foundation.h>
#import "DNMacro.h"
#import "dart_api_dl.h"
#import "native_runtime.h"

#ifndef DNBlockCreator_h
#define DNBlockCreator_h

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
    void *creator;
} DNBlock;

#pragma mark - Block Creator

DN_EXTERN const char *DNBlockTypeEncodeString(id blockObj);
DN_EXTERN const char *_Nonnull *_Nonnull DNBlockTypeEncodings(id blockObj);
DN_EXTERN uint64_t DNBlockSequence(id blockObj);


typedef void (*BlockFunctionPointer)(void *_Nullable *_Null_unspecified args, void *ret, int numberOfArguments, BOOL stret, int64_t seq);

@interface DNBlockCreator : NSObject

@property (nonatomic, readonly) const char *_Nonnull *_Nonnull typeEncodings;
@property (nonatomic, readonly) BlockFunctionPointer function;
@property (nonatomic, readonly, getter=shouldReturnAsync) BOOL returnAsync;
@property (nonatomic, getter=hasStret, readonly) BOOL stret;
@property (nonatomic, readonly) NSMethodSignature *signature;
@property (nonatomic, readonly) uint64_t sequence;
@property (nonatomic, readonly) Dart_Port dartPort;

- (instancetype)initWithTypeString:(char *)typeString
                          function:(BlockFunctionPointer)function
                       returnAsync:(BOOL)returnAsync
                          dartPort:(Dart_Port)dartPort
                             error:(out NSError **)error;
- (id)blockWithError:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif
