//
//  DNInterfaceRegistry.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/2/6.
//

#import <Foundation/Foundation.h>
#import "DNMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *DartNativeInterfaceMap;

DN_EXTERN BOOL DartNativeRegisterInterface(NSString *name, Class cls);
DN_EXTERN NSObject *DNInterfaceHostObjectWithName(NSString *name);
DN_EXTERN DartNativeInterfaceMap DNInterfaceAllMetaData(void);

NS_ASSUME_NONNULL_END
