//
//  Observer.m
//  debug-objc
//
//  Created by xu yanjun on 2018/4/24.
//

#import "Observer.h"

@implementation Observer
- (void)observePath:(NSString *)keyPath object:(id)object change:(NSDictionary *)change info:(id)info
{
    NSLog(@"%@", keyPath);
}
@end
