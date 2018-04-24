//
//  Animal.m
//  debug-objc
//
//  Created by xu yanjun on 2018/2/9.
//

#import "Animal.h"

@interface Animal () {
    int _privateIva1;
}

@end

@implementation Animal  {
    int _privateIva2;
}

- (void)run {
//    NSLog(@"%@ run", self);
    //这个方法的意思是：用self去调用自己的class方法，底层调用id objc_msgSend(id _Nullable self, SEL _Nonnull op, ...)
    [self class];
    /*这个方法的意思是：用self去调用父类的class方法，底层调用id objc_msgSendSuper(struct objc_super * _Nonnull super, SEL _Nonnull op, ...)
     struct objc_super {
        /// Specifies an instance of a class.
        __unsafe_unretained id receiver;
     
        /// Specifies the particular superclass of the instance to message.
        __unsafe_unretained Class super_class;
     };
     调用时，super传入的是objc_super类型的局部变量(objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Animal"))}，receiver是self，方法列表从父类super_class中找
     */
    [super class];
}

+ (void)clsMethod {
    
}

- (void)dealloc {
    NSLog(@"*******Animal: %@ dealloc*******", self.class);
}
@end
