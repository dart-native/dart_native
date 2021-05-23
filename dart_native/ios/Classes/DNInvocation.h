//
//  DNInvocation.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNInvocation : NSObject

/**
 YES if the receiver has retained its arguments, NO otherwise.
 */
@property (nonatomic, getter=isArgumentsRetained, readwrite) BOOL argumentsRetained;

/**
 The block's method signature.
 */
@property (nonatomic, strong, readonly) NSMethodSignature *methodSignature;
@property (nonatomic, readwrite) void *_Nullable *_Null_unspecified args;
@property (nonatomic, nullable, readwrite) void *retValue;
@property (nonatomic) void *_Nullable *_Null_unspecified realArgs;
@property (nonatomic, nullable) void *realRetValue;

- (instancetype)initWithSignature:(NSMethodSignature *)signature hasStret:(BOOL)stret;

/**
 If the receiver hasn’t already done so, retains the target and all object arguments of the receiver and copies all of its C-string arguments and blocks. If a returnvalue has been set, this is also retained or copied.
 */
- (void)retainArguments;

/**
 Gets the receiver's return value.
 If the NSInvocation object has never been invoked, the result of this method is undefined.

 @param retLoc An untyped buffer into which the receiver copies its return value. It should be large enough to accommodate the value. See the discussion in NSInvocation for more information about buffer.
 */
- (void)getReturnValue:(void *)retLoc;

/**
 Sets the receiver’s return value.

 @param retLoc An untyped buffer whose contents are copied as the receiver's return value.
 @discussion This value is normally set when you invoke block.
 */
- (void)setReturnValue:(void *)retLoc;

/**
 Sets an argument of the receiver.

 @param argumentLocation An untyped buffer containing an argument to be assigned to the receiver. See the discussion in NSInvocation relating to argument values that are objects.
 @param idx An integer specifying the index of the argument. Indices 0 indicates self, use indices 1 and greater for the arguments normally passed in an invocation.
 */
- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx;

/**
 Sets an argument of the receiver.

 @param argumentLocation An untyped buffer containing an argument to be assigned to the receiver. See the discussion in NSInvocation relating to argument values that are objects.
 @param idx An integer specifying the index of the argument. Indices 0 indicates self, use indices 1 and greater for the arguments normally passed in an invocation.
 */
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx;

@end

NS_ASSUME_NONNULL_END
