//
//  NSValue+DNUnwrapValues.m
//  dart_native
//
//  Created by 杨萧玉 on 2022/2/20.
//

#import "NSNumber+DNUnwrapValues.h"

#if !__has_feature(objc_arc)
#error
#endif

typedef void(^DNBufferSetAction)(NSNumber *num, void **buffer);
typedef NSNumber *(^DNBufferGetAction)(void *buffer);

@implementation NSNumber (DNUnwrapValues)

static NSDictionary<NSNumber *, DNBufferSetAction> *gArgumentTypeSetStrategy;
static NSDictionary<NSNumber *, DNBufferGetAction> *gArgumentTypeGetStrategy;

- (BOOL)dn_fillBuffer:(void **)buffer
             encoding:(const char *)encoding
                error:(out NSError **)error {
    /** Doing this type switching below because when we call NSNumber's methods like 'doubleValue' or 'floatValue',
    * value will be converted if necessary. (instead of approach when we just copy bytes - see NSValue category)
    * That will handle situation when for example argumentType is float, but NSNumber's type is double */

    if (!gArgumentTypeSetStrategy) {
        NSMutableDictionary<NSNumber *, DNBufferSetAction> *temp = [NSMutableDictionary dictionary];
         
#define SET_ARG_METHOD(type, method) \
        temp[@(*@encode(type))] = ^void(NSNumber *num, void **buffer) { \
            type converted = [num method]; \
            if (!buffer) { \
                return; \
            } \
            NSUInteger argSize; \
            NSGetSizeAndAlignment(@encode(type), &argSize, NULL); \
            memcpy(buffer, (void *)&converted, argSize); \
        };
#define SET_ARG(type) SET_ARG_METHOD(type, type##Value)
        
        temp[@(*@encode(id))] = ^void(NSNumber *num, void **buffer) {
            id converted = num;
            if (!buffer) {
                return;
            }
            NSUInteger argSize;
            NSGetSizeAndAlignment(@encode(id), &argSize, NULL);
            memcpy(buffer, (void *)&converted, argSize);
        };
        SET_ARG(int)
        SET_ARG_METHOD(unsigned int, unsignedIntValue)
        SET_ARG(char)
        SET_ARG_METHOD(unsigned char, unsignedCharValue)
        SET_ARG(bool)
        SET_ARG(short)
        SET_ARG_METHOD(unsigned short, unsignedShortValue)
        SET_ARG(float)
        SET_ARG(double)
        SET_ARG(long)
        SET_ARG_METHOD(unsigned long, unsignedLongValue)
        SET_ARG_METHOD(long long, longLongValue)
        SET_ARG_METHOD(unsigned long long, unsignedLongLongValue)
        SET_ARG_METHOD(NSInteger, integerValue)
        SET_ARG_METHOD(NSUInteger, unsignedIntegerValue)
        gArgumentTypeSetStrategy = [temp copy];
    }
    
    DNBufferSetAction action = gArgumentTypeSetStrategy[@(*encoding)];
    if (action) {
        action(self, buffer);
    } else {
        DN_ERROR(error, DNUnwrapValueError, @"Invalid Number: Type '%s' is not supported.", encoding)
        return NO;
    }
    return YES;
}

+ (instancetype)dn_numberWithBuffer:(void *)buffer
                           encoding:(const char *)encoding
                              error:(out NSError **)error {
    if (!gArgumentTypeGetStrategy) {
        NSMutableDictionary<NSNumber *, DNBufferGetAction> *temp = [NSMutableDictionary dictionary];
#define DNConcat(a, b) a##b
#define GET_ARG_METHOD(type, method) \
    temp[@(*@encode(type))] = ^NSNumber *(void *buffer) { \
        if (!buffer) { \
            return nil; \
        } \
        type num; \
        NSUInteger argSize; \
        NSGetSizeAndAlignment(@encode(type), &argSize, NULL); \
        memcpy((void *)&num, &buffer, argSize); \
        return [NSNumber DNConcat(numberWith, method):num]; \
    };
        GET_ARG_METHOD(int, Int)
        GET_ARG_METHOD(unsigned int, UnsignedInt)
        GET_ARG_METHOD(char, Char)
        GET_ARG_METHOD(unsigned char, UnsignedChar)
        GET_ARG_METHOD(bool, Bool)
        GET_ARG_METHOD(short, Short)
        GET_ARG_METHOD(unsigned short, UnsignedShort)
        GET_ARG_METHOD(float, Float)
        GET_ARG_METHOD(double, Double)
        GET_ARG_METHOD(long, Long)
        GET_ARG_METHOD(unsigned long, UnsignedLong)
        GET_ARG_METHOD(long long, LongLong)
        GET_ARG_METHOD(unsigned long long, UnsignedLongLong)
        GET_ARG_METHOD(NSInteger, Integer)
        GET_ARG_METHOD(NSInteger, UnsignedInteger)
        gArgumentTypeGetStrategy = [temp copy];
    }

    DNBufferGetAction action = gArgumentTypeGetStrategy[@(*encoding)];
    if (action) {
        return action(buffer);
    } else {
        DN_ERROR(error, DNUnwrapValueError, @"Invalid Number: Type '%s' is not supported.", encoding)
        return nil;
    }
}

@end
