//
//  KVOClass.m
//  debug-objc
//
//  Created by xu yanjun on 2018/4/24.
//

#import "KVOClass.h"

@implementation KVOClass

- (void)setKvoProperty:(NSString *)kvoProperty {
    _kvoProperty = kvoProperty;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self.class);
}
@end
