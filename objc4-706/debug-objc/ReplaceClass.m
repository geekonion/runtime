//
//  ReplaceClass.m
//  debug-objc
//
//  Created by xu yanjun on 2018/4/24.
//

#import "ReplaceClass.h"

@implementation ReplaceClass

- (void)dealloc {
    
    NSLog(@"dealloc %@", self.class);
}

@end
