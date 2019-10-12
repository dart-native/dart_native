//
//  RuntimeStub.m
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import "RuntimeStub.h"
#import <UIKit/UIKit.h>

@implementation RuntimeStub

- (int8_t)foo0:(id)a
{
    return -123;
}

- (int16_t)foo1:(id)a
{
    
    return -12345;
}

- (int32_t)foo2:(id)a
{
    
    return -123456;
}

- (int64_t)foo3:(id)a
{
    
    return -123456;
}

- (uint8_t)foo4:(id)a
{
    
    return 123;
}

- (uint16_t)foo5:(id)a
{
    
    return 12345;
}

- (uint32_t)foo6:(id)a
{
    
    return 123456;
}

- (uint64_t)foo7:(id)a
{
    
    return 123456;
}

- (float)foo8:(id)a
{
    
    return 123.456;
}

- (double)foo9:(id)a
{
    
    return 123.456;
}

- (char *)foo10:(id)a
{
    
    return "123456";
}

- (Class)foo11:(id)a
{
    [RuntimeStub superclass];
    Class cls = [[RuntimeStub class] superclass];
    return [RuntimeStub class];
}

- (SEL)foo12:(id)a
{
    return _cmd;
}

- (id)foo13:(id)a
{
    
    return self;
}

- (void *)foo14:(id)a
{
    
    return (__bridge void *)(self);
}

- (void)foo15:(id)a
{
    
    return;
}

@end
