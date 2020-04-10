//
//  Cash.m
//  硬件检测
//
//  Created by hello on 2020/4/10.
//  Copyright © 2020 baixinyinhang. All rights reserved.
//


//Crash分为两种，一种是由EXC_BAD_ACCESS引起的，原因是访问了不属于本进程的内存地址，有可能是访问已被释放的内存；另一种是未被捕获的Objective-C异常（NSException），导致程序向自身发送了SIGABRT信号而崩溃

#import "Cash.h"
#import <execinfo.h>

@implementation Cash

//检测第一种是由EXC_BAD_ACCESS引起的
void CrashExceptionHandler(NSException *exception){
    NSArray *callStack = [exception callStackSymbols];
    NSString *reson = [exception reason];
    NSString *name = [exception name];
    NSLog(@"%@\n---%@\n--%@",callStack,reson,name);
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSString stringWithFormat:@"%@\n%@\n%@",callStack,reson,name] forKey:@"cashKey1"];
    [user synchronize];
   //TODO: 保存奔溃信息到本地，下次启动的时候上传到服务器
}
//检测第二种是未被捕获的Objective-C异常（NSException），导致程序向自身发送了SIGABRT信号而崩溃
void handleSignal(int signal) {
    NSArray *callStack = [Cash backtrace];
    NSLog(@"信号捕获崩溃，堆栈信息：%@",callStack);
    NSString *name = @"SignalException";
    NSString *reason = [NSString stringWithFormat:@"signal %d was raised",signal];
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
     [user setObject:[NSString stringWithFormat:@"%@",callStack] forKey:@"cashKey2"];
     [user synchronize];
}
+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

+ (instancetype)defaultCash
{
    static dispatch_once_t onceToken;
    static Cash *cash = nil;
    dispatch_once(&onceToken, ^{
        cash = [[Cash alloc]init];
//检测第一种
        NSSetUncaughtExceptionHandler(&CrashExceptionHandler);
        //检测第二种
        //注册程序由于abort()函数调用发生的程序中止信号
        signal(SIGABRT, handleSignal);
        //注册程序由于非法指令产生的程序中止信号
        signal(SIGILL, handleSignal);
        //注册程序由于无效内存的引用导致的程序中止信号
        signal(SIGSEGV, handleSignal);
        //注册程序由于浮点数异常导致的程序中止信号
        signal(SIGFPE, handleSignal);
        //注册程序由于内存地址未对齐导致的程序中止信号
        signal(SIGBUS, handleSignal);
        //程序通过端口发送消息失败导致的程序中止信号
        signal(SIGPIPE, handleSignal);
    });
    return cash;
}


@end
