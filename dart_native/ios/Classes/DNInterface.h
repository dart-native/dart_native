//
//  DNInterface.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/21.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"
#import "DNTypeEncoding.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BlockResultCallback)(id _Nullable result, NSError * _Nullable error);
typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *DartNativeInterfaceMap;

DN_EXTERN NSObject *DNInterfaceHostObjectWithName(char *name);
DN_EXTERN DartNativeInterfaceMap DNInterfaceAllMetaData(void);
DN_EXTERN void DNInterfaceRegisterDartInterface(char *interface, char *method, id block, Dart_Port port);
DN_EXTERN void DNInterfaceBlockInvoke(void *block, NSArray *arguments, BlockResultCallback resultCallback);

NS_ASSUME_NONNULL_END
