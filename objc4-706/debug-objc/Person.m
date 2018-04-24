//
//  Person.m
//  objc
//
//  Created by 蓝布鲁 on 2016/12/29.
//
//

#import "Person.h"

@implementation Person

+ (void)load {
    [super load];
}

+ (void)initialize {
    [super initialize];
}

+ (NSString *)species{
    return @"Person";
}

- (void)sayHello{
    NSLog(@"Hello!!!");
}

- (void)run {
    NSLog(@"%@ run", self);
}

- (void)dealloc {
    NSLog(@"*******Person: %@ dealloc*******", self.class);
}



@end
