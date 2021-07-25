//
//  DNDartPortsContainer.h
//  dart_native
//
//  Created by 杨萧玉 on 2021/7/18.
//

#import <Foundation/Foundation.h>
#import "dart_api_dl.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNAssociatedDartObject : NSObject

@property (nonatomic, readonly, weak) NSObject *host;
// Object can be passed on multi-isolates.
@property (nonatomic, readonly) NSSet<NSNumber *> *dartPorts;

- (instancetype)initWithHost:(NSObject *)host
                  storageKey:(const void *)storageKey;
+ (instancetype)attachHost:(NSObject *)host
                  dartPort:(Dart_Port)dartPort
                storageKey:(const void *)storageKey;
+ (instancetype)objectForHost:(NSObject *)host
                   storageKey:(const void *)storageKey;
@end

NS_ASSUME_NONNULL_END
