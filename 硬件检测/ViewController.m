//
//  ViewController.m
//  硬件检测
//
//  Created by hello on 2020/4/9.
//  Copyright © 2020 baixinyinhang. All rights reserved.
//

#import "ViewController.h"
//cpu
#import <mach/mach.h>
#import <assert.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *cpu;
@property (weak, nonatomic) IBOutlet UITextView *cashContent;

@end

@implementation ViewController
{
    dispatch_source_t timer;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"cpu用量:%f",[self CpuUsage]);
        self.cpu.text = [NSString stringWithFormat:@"cpu用量:%f",[self CpuUsage]];
    });
    dispatch_resume(timer);
    
}



//cpu（方法一，据说是腾讯GT）
- (float)CpuUsage
{
    kern_return_t           kr;
    thread_array_t          thread_list;
    mach_msg_type_number_t  thread_count;
    thread_info_data_t      thinfo;
    mach_msg_type_number_t  thread_info_count;
    thread_basic_info_t     basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
  float  cpu_usage = 0;
    
    for (int i = 0; i < thread_count; i++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            cpu_usage += basic_info_th->cpu_usage;
        }
    }
    
    cpu_usage = cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return cpu_usage;
}
- (IBAction)cashClick:(id)sender {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * cashContent = [userDefaults objectForKey:@"cashKey"];
    NSLog(@"%@",cashContent);
    if (cashContent) {
        self.cashContent.text =cashContent;
        [userDefaults setObject:nil forKey:@"cashKey"];
    }else{
        [self ceshi];
    }
    
}
- (void)ceshi{
    @[][1];
}


@end
