//
//  RealClass.m
//  debug-objc
//
//  Created by xu yanjun on 2018/4/24.
//

#import "RealClass.h"
#import "Person.h"

@implementation RealClass {
    id _testLeak;
}

- (instancetype)init {
    if (self = [super init]) {
        _testLeak = [[Person alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self.class);
}

@end
