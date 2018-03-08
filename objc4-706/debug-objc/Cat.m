//
//  Cat.m
//  debug-objc
//
//  Created by xu yanjun on 2018/2/9.
//

#import "Cat.h"

@implementation Cat

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%@", [self class]);
        NSLog(@"%@", [super class]);
    }
    
    return self;
}

- (void)run {
    NSLog(@"***%@ run***", self);
}

- (void)dealloc {
    NSLog(@"*******Cat: %@ dealloc*******", self.class);
}

@end
