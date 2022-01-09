//
//  NSObject+DartHandleExternalSize.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/1/9.
//

#import "NSObject+DartHandleExternalSize.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "DNBlockWrapper.h"

@implementation NSObject (DartHandleExternalSize)

- (size_t)dn_objectSize {
    size_t result = 0;
    Class cls = object_getClass(self);
    if (!cls) {
        return sizeof(void *);
    }
    result = class_getInstanceSize(cls);
    unsigned int countOfIvars;
    Ivar *ivars = class_copyIvarList(cls, &countOfIvars);
    for (int i = 0; i < countOfIvars; i++) {
        Ivar iv = ivars[i];
        const char *typeEncoding = ivar_getTypeEncoding(iv);
        if (typeEncoding[0] == @encode(id)[0]) {
            id obj = object_getIvar(self, iv);
            if (!obj) {
                continue;;
            }
            if (strcmp(typeEncoding, "@?") == 0) {
                // size of __NSMallocBlock
                result += sizeof(DNBlock);
            } else {
                // size of NSObject
                result += [obj dn_objectSize];
            }
        } else if (typeEncoding[0] == @encode(void *)[0]) {
            // size of malloc pointer
            void *ptr = *(void **)((intptr_t)self + ivar_getOffset(iv));
            size_t size = malloc_size(ptr);
            result += size;
        } else if (typeEncoding[0] == @encode(char *)[0]) {
            // size of C-String
            const char *ptr = *(const char **)((intptr_t)self + ivar_getOffset(iv));
            size_t size = (strlen(ptr) + 1) * sizeof(char);
            result += size;
        }
    }
    free(ivars);
    return result;
}

@end

@implementation NSArray (DartHandleExternalSize)

- (size_t)dn_objectSize {
    size_t result = [super dn_objectSize];
    for (id object in self) {
        if ([object isKindOfClass:NSClassFromString(@"__MallocBlock")]) {
            result += sizeof(DNBlock);
        } else {
            result += [object dn_objectSize];
        }
    }
    return result;
}

@end

@implementation NSDictionary (DartHandleExternalSize)

- (size_t)dn_objectSize {
    __block size_t result = [super dn_objectSize];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        result += [key dn_objectSize];
        if ([obj isKindOfClass:NSClassFromString(@"__MallocBlock")]) {
            result += sizeof(DNBlock);
        } else {
            result += [obj dn_objectSize];
        }
    }];
    return result;
}

@end

@implementation NSSet (DartHandleExternalSize)

- (size_t)dn_objectSize {
    size_t result = [super dn_objectSize];
    for (id object in self) {
        if ([object isKindOfClass:NSClassFromString(@"__MallocBlock")]) {
            result += sizeof(DNBlock);
        } else {
            result += [object dn_objectSize];
        }
    }
    return result;
}

@end
