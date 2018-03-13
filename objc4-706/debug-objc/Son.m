//
//  Son.m
//  debug-objc
//
//  Created by xu yanjun on 2018/2/27.
//

#import "Son.h"
#import "Sark.h"
#import "Person.h"
#import "Animal.h"

@implementation Son
- (void)paly {
    /*调用super和不调用，对后续代码的影响：
     1.如果调用了super，cls入栈后，cls下一个位置是个对象(姑且叫obj)，调用[(__bridge id)obj speak]时，self.name会调用objc_getProperty()，返回的就是obj，随后会调用objc_retain()，调用obj->retain()，由于obj本身是个对象，所以是能正常运行的；
     2.而如果不调用super，cls入栈后，cls下一个位置是_cmd(SEL名为"play")，self.name返回的就是SEL，用SEL去调用对象的一系列方法就会崩溃；
     3.按以上两点可以推出，只要cls入栈前，栈顶是对象即可，经测试证明，推论是成立的。
     */
    
    [super paly];
//    NSString *str = @"test";
    
    id cls = [Sark class];
    void *obj = &cls;
    [(__bridge id)obj speak];
    
    Sark *sark = [[Sark alloc] init];
    sark.name = @"sark";
    sark.alias = @"sweety";
    [sark speak]; //验证时，在这行下断点
    
    /*
     1.验证Sark对象内存分布
     (lldb) po sark
     <Sark: 0x100b03fe0>                                        //堆上的真实Sark对象
     
     (lldb) x/10g 0x100b03fe0
     0x100b03fe0: 0x001d800100002e3d 0x0000000100002108
     0x100b03ff0: 0x0000000100002128 0x0000000000000000
     0x100b04000: 0x0000000000000000 0x0000000000000000
     0x100b04010: 0x0000000100b00003 0x00007fff8315afd8
     0x100b04020: 0x0000000100b01140 0x00037fff86297948
     (lldb) po 0x0000000100002108
     sark                                                       //从对象起始地址起，偏移16位是第一个属性
     
     (lldb) po 0x0000000100002128
     sweety                                                     //从对象起始地址起，偏移32位是第二个属性
     
     
     2.解释为什么调用[(__bridge id)obj speak]会输出my name's <Son: 0x100e3c480>，即当前的self
     
     (lldb) po obj
     <Sark: 0x7ffeefbff4a8>                                     //栈上的地址0x7ffeefbff4a8被当作Sark对象使用，为什么会是Sark对象，
                                                                这是问题的关键，后面的现象完全遵守上面验证的内存分布
                                                                因为，类和对象都是objc_object类型，前64位都是union isa_t变量即isa指针
                                                                objc-private.h定义x86_64中ISA_MASK = 0x00007ffffffffff8UL
                                                                0x001d800100002e3d & ISA_MASK的意义：取0x001d800100002e3d中倒数第47到倒数第4位
                                                                共44位，然后左移3位，即shiftcls
     
                                                                0x001d800100002e3d & ISA_MASK = 0x0000000100002e38
                                                                0x0000000100002e38 & ISA_MASK = 0x0000000100002e38
                                                                即shiftcls相同
     
                                                                0x001d800100002e3d中的1d8是magic用于调试器判断当前对象是真的对象还是没有初始化的空间
     
                                                                从以上可以推论，64位架构下，任意对象的前64位跟ISA_MASK按位与就可以得到他的类对象
                                                                arm64中，shiftcls是33位，所以ISA_MASK = 0x0000000FFFFFFFF8UL
                                                                经测试，证明推论正确
     
     (lldb) x/10g 0x7ffeefbff4a8                                //打印该“对象”内存分布
     0x7ffeefbff4a8: 0x0000000100002e38 0x0000000100e3c480
     0x7ffeefbff4b8: 0x0000000100002d70 0x0000000100001c2c
     0x7ffeefbff4c8: 0x0000000100e3c480 0x00007ffeefbff4f0
     0x7ffeefbff4d8: 0x0000000100001565 0x00007ffeefbff4f0
     0x7ffeefbff4e8: 0x0000000100e3c480 0x00007ffeefbff520
     (lldb) po 0x0000000100e3c480                               //从对象起始地址起，偏移16位被当作是self.name，实际上是<Son: 0x100e3c480>
     <Son: 0x100e3c480>
     
     (lldb) po [obj speak]
     2018-02-27 19:36:09.795745+0800 debug-objc[11788:1823786] my name's <Son: 0x100e3c480>
     
     3.堆栈图验证
     (lldb) x/10g &sark
     0x7ffeefbff498: 0x0000000100b03fe0 0x00007ffeefbff4a8
     0x7ffeefbff4a8: 0x0000000100002e38 0x0000000100e3c480
     0x7ffeefbff4b8: 0x0000000100002d70 0x0000000100001c2c
     0x7ffeefbff4c8: 0x0000000100e3c480 0x00007ffeefbff4f0
     0x7ffeefbff4d8: 0x0000000100001565 0x00007ffeefbff4f0
     (lldb) po 0x0000000100b03fe0
     <Sark: 0x100b03fe0>
     
     (lldb) po 0x00007ffeefbff4a8
     <Sark: 0x7ffeefbff4a8>
     
     (lldb) po 0x0000000100002e38
     Sark
     
     (lldb) po 0x0000000100e3c480
     <Son: 0x100e3c480>
     
     (lldb) po 0x0000000100002d70
     Son
     
     (lldb) po (char *)0x0000000100001c2c
     "paly"
     
     (lldb) po self
     <Son: 0x100e3c480>
     
     //objc_msgSend原型 id objc_msgSend(id self, SEL op, ...)
     
     堆栈图：
     0x7ffeefbff498: | 0x0000000100b03fe0 |    -->局部变量sark，即最后创建的真实Sark对象
                     | 0x00007ffeefbff4a8 |    -->局部变量obj，即假Sark对象
     0x7ffeefbff4a8: | 0x0000000100002e38 |    -->局部变量cls，即Sark类
                     | 0x0000000100e3c480 |    -->self
                     | 0x0000000100002d70 |    -->Son      //此处的self和Son合起来应该是调用[super play]时的objc_super变量，是个局部变量，所以还在栈里(为什么不是Father)
                     | 0x0000000100001c2c |    -->_cmd "paly"
     0x7ffeefbff4c8: | 0x0000000100e3c480 |    -->self
     */
}

@end
